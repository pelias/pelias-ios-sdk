//
//  SearchManager.swift
//  PlayMap
//
//  Created by Matt on 11/13/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

/// Main entry point for Pelias. Use this singleton to execute geo requests.
public final class PeliasSearchManager {
  
  //! Singleton access
  public static let sharedInstance = PeliasSearchManager()
  internal let operationQueue = OperationQueue()
  fileprivate let autocompleteOperationQueue = OperationQueue()
  fileprivate var autocompleteQueryTimer: Timer?
  internal var queuedAutocompleteOp: PeliasOperation?
  /// Delay in seconds that the manager should wait between keystrokes to fire a new autocomplete request
  public var autocompleteTimeDelay: Double = 0.0
  /// Base url to execute requests against. Default value is https://search.mapzen.com.
  public var baseUrl: URL
  /// The query items that should be applied to every request (such as an api key).
  public var urlQueryItems: [URLQueryItem]?
  // Additional HTTP Headers to append to outbound requests
  public var additionalHttpHeaders: [String:String]?
  
  fileprivate init() {
    operationQueue.maxConcurrentOperationCount = 4
    autocompleteOperationQueue.maxConcurrentOperationCount = 1
    baseUrl = URL.init(string: Constants.URL.base)! // Force the unwrap because we must have a base URL to operate
  }

  /** Perform an asynchronous search request given parameters defined by the search config. Returns the queued operation.
    - parameter config: Object holding search request parameter information.
  */
  public func performSearch(_ config: PeliasSearchConfig) -> PeliasOperation {
    return executeOperation(config);
  }

  /** Perform an asynchronous reverse geocode request given parameters defined by the config. Returns the queued operation.
   - parameter config: Object holding reverse geo request parameter information.
   */
  public func reverseGeocode(_ config: PeliasReverseConfig) -> PeliasOperation {
    return executeOperation(config);
  }

  /** Perform an asynchronous autocomplete request given parameters defined by the config. Returns the queued operation.
   - parameter config: Object holding autocomplete request parameter information.
   */
  public func autocompleteQuery(_ config: PeliasAutocompleteConfig) -> PeliasOperation {
    
    return executeAutocompleteOperation(config)
  }

  /** Perform an asynchronous place request given parameters defined by the search config. Returns the queued operation.
   - parameter config: Object holding place request parameter information.
   */
  public func placeQuery(_ config: PeliasPlaceConfig) -> PeliasOperation {
    return executeOperation(config)
  }

  /// Cancel all requests
  public func cancelOperations() {
    self.operationQueue.cancelAllOperations()
    self.autocompleteOperationQueue.cancelAllOperations()
  }

  fileprivate func createOperation(_ config: APIConfigData) -> PeliasOperation {
    //Convert to mutable version, and append any query items we have waiting for us
    var configData = config
    if let urlQueryItems = urlQueryItems {
      for queryItem in urlQueryItems {
        configData.appendQueryItem(queryItem.name, value: queryItem.value)
      }
    }

    let operation = PeliasOperation(config: configData)
    if let headers = additionalHttpHeaders {
      let config = URLSessionConfiguration.default
      config.httpAdditionalHeaders = headers
      operation.sessionConfig = config
    }

    //Build a operation
    return operation
  }
  
  fileprivate func executeOperation(_ config: APIConfigData) -> PeliasOperation {
    let searchOp = createOperation(config)
    //Enqueue search object so it can begin processing
    operationQueue.addOperation(searchOp)
    
    return searchOp;
  }
  
  fileprivate func executeAutocompleteOperation(_ config: PeliasAutocompleteConfig) -> PeliasOperation {
    //Rate Limiter
    //First we check to see if we have a delay stored - if not, we use the existing operation queue to immediately fire
    if (autocompleteTimeDelay <= 0) {
      return executeOperation(config)
    }
    
    let operation = createOperation(config)
    queuedAutocompleteOp = operation
    // We may be executing an existing operation, so lets see if we have a timer
    // Conceivably this could get called from multiple threads, in which case we should probably synchronize on the timer variable. We'll deal with that if it comes to that
    if autocompleteQueryTimer == nil {
      //We don't have a timer, so lets boot one up and start the engine ticking
      self.autocompleteTimerExecute()
    }
    
    return operation
  }
  
  @objc fileprivate func autocompleteTimerExecute() {
    //Check to see if we have an operation waiting for us
    if let operation = queuedAutocompleteOp {
      //We have one! Lets fire it, and then create a new timer that will fire once in whatever delay there is from now
      print("Engaging Rate limiter")
      autocompleteOperationQueue.addOperation(operation)
      queuedAutocompleteOp = nil
      autocompleteQueryTimer = Timer.scheduledTimer(timeInterval: autocompleteTimeDelay, target: self, selector: #selector(PeliasSearchManager.autocompleteTimerExecute), userInfo: nil, repeats: false)
    }
    else {
      //We don't have one! Set it to nil so we come back into this function
      autocompleteQueryTimer = nil
    }
  }
}

/// Represents a queued operation executed by the search manager. Handles creating a PeliasResponse object and sending it to the completion handler.
open class PeliasOperation: Operation {
  
  let config: APIConfigData
  var session = URLSession.shared

  /// An optional configuration you can pass to the underlying URLSession system if you need some special handling.
  public var sessionConfig: URLSessionConfiguration?

  /**
   Creates a new operation given a config. The config will be used to construct a proper response object.
   - parameter config: The config used to create a new operation and response
   */
  public init(config: APIConfigData) {
    self.config = config
  }
  
  override open func main() {
    if self.isCancelled {
      return
    }

    if let sessionConfig = sessionConfig {
      session = URLSession(configuration: sessionConfig)
    }
    
    session.dataTask(with: config.searchUrl()) { (data, response, error) in
      if self.isCancelled {
        return
      }
      let searchResponse = PeliasResponse(data: data, response: response, error: error as NSError?)
      OperationQueue.main.addOperation({ () -> Void in
        if self.isCancelled {
          return
        }
        self.config.completionHandler(searchResponse)
      })
    }.resume()
  }
}

/// Represents a response for a request executed by the 'PeliasSearchManager'
open class PeliasResponse: APIResponse {
  /// The raw data response
  open let data: Data?
  /// The url response if the request completed successfully.
  open let response: URLResponse?
  /// The error if an error occured executing the operation.
  open var error: NSError?
  ///
  open var parsedResponse: PeliasSearchResponse?

  private static let validTypes: Set = ["Point", "MultiPoint", "LineString", "MultiLineString", "Polygon", "MultiPolygon", "GeometryCollection", "Feature", "FeatureCollection"]

  public init(data: Data?, response: URLResponse?, error: NSError?) {
    self.data = data
    self.response = response
    self.error = error
    if let dictResponse: Dictionary<String, Any> = parseData(data) {
      if let type = dictResponse["type"] as? String {
        if PeliasResponse.validTypes.contains(type) {
          parsedResponse = PeliasSearchResponse(parsedResponse: dictResponse)
        }
      } else {
        let meta = dictResponse["meta"] as? NSDictionary
        guard let code = meta?["status_code"] as? Int else { return }
        let results = dictResponse["results"] as? NSDictionary
        let error = results?["error"]  as? NSDictionary
        guard let message = error?["message"] else { return }
        self.error = NSError.init(domain: "Pelias", code: code, userInfo: [NSLocalizedDescriptionKey:message])
      }
    }
  }

  fileprivate func parseData<T>(_ data: Data?) -> T?  {
    guard let jsonData = data else { return nil }
    let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
    return jsonObj as? T
  }
}

/// Response that can be saved to disk
public struct PeliasSearchResponse {
  /// Response data that will be saved to disk.
  public let parsedResponse: Dictionary<String, Any>

  /// Constructs a new response given a response dictionary from the server.
  public init(parsedResponse: Dictionary<String, Any>) {
    self.parsedResponse = parsedResponse
  }

  /// Saves the response's data to documents directory.
  public static func encode(_ response: PeliasSearchResponse) {
    guard let docsPath = HelperClass.path() else { return }
    let personClassObject = HelperClass(response: response)
    
    NSKeyedArchiver.archiveRootObject(personClassObject, toFile: docsPath)
  }

  /// Returns a response read from the documents directory and populated with all of the saved searches.
  public static func decode() -> PeliasSearchResponse? {
    guard let docsPath = HelperClass.path() else { return nil }
    let responseClassObject = NSKeyedUnarchiver.unarchiveObject(withFile: docsPath) as? HelperClass
    
    return responseClassObject?.response
  }
}

extension PeliasSearchResponse {
  
  //TODO: I'm still not sure of this approach - might be better to implement something more like a proper protocol like http://redqueencoder.com/property-lists-and-user-defaults-in-swift but this works for now
  open class HelperClass: NSObject, NSCoding {
    
    open var response: PeliasSearchResponse?
    
    public init(response: PeliasSearchResponse) {
      self.response = response
      super.init()
    }
    
    class func path() -> String? {
      let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
      guard let docsPath = documentsPath else { return nil }
      let path = docsPath + "/Response"
      return path
    }
    
    public required init?(coder aDecoder: NSCoder) {
      guard let parsedResponse = aDecoder.decodeObject(forKey: "parsedResponse") as? Dictionary<String, Any> else { response = nil; super.init(); return nil }
      
      response = PeliasSearchResponse(parsedResponse: parsedResponse)
      
      super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
      aCoder.encode(response!.parsedResponse, forKey: "parsedResponse")
    }
  }
}
