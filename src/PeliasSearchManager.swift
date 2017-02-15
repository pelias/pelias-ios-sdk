//
//  SearchManager.swift
//  PlayMap
//
//  Created by Matt on 11/13/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public final class PeliasSearchManager {
  
  //! Singleton access
  public static let sharedInstance = PeliasSearchManager()
  fileprivate let operationQueue = OperationQueue()
  fileprivate let autocompleteOperationQueue = OperationQueue()
  fileprivate var autocompleteQueryTimer: Timer?
  internal var queuedAutocompleteOp: PeliasOperation?
  public var autocompleteTimeDelay: Double = 0.0 //In seconds
  public var baseUrl: URL
  public var urlQueryItems: [URLQueryItem]?
  
  fileprivate init() {
    operationQueue.maxConcurrentOperationCount = 4
    autocompleteOperationQueue.maxConcurrentOperationCount = 1
    baseUrl = URL.init(string: Constants.URL.base)! // Force the unwrap because we must have a base URL to operate
  }
  
  public func performSearch(_ config: PeliasSearchConfig) -> PeliasOperation {
    return executeOperation(config);
  }
  
  public func reverseGeocode(_ config: PeliasReverseConfig) -> PeliasOperation {
    return executeOperation(config);
  }
  
  public func autocompleteQuery(_ config: PeliasAutocompleteConfig) -> PeliasOperation {
    
    return executeAutocompleteOperation(config)
  }
  
  public func placeQuery(_ config: PeliasPlaceConfig) -> PeliasOperation {
    return executeOperation(config)
  }
  
  public func cancelOperations() {
    self.operationQueue.cancelAllOperations()
    self.autocompleteOperationQueue.cancelAllOperations()
  }
  
  fileprivate func executeOperation(_ config: APIConfigData) -> PeliasOperation {
    //Convert to mutable version, and append any query items we have waiting for us
    var configData = config
    if let urlQueryItems = urlQueryItems {
      for queryItem in urlQueryItems {
        configData.appendQueryItem(queryItem.name, value: queryItem.value)
      }
    }
    //Build a operation
    let searchOp = PeliasOperation(config: configData)
    
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
    
    let operation = PeliasOperation(config: config)
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

open class PeliasOperation: Operation {
  
  let config: APIConfigData
  
  public init(config: APIConfigData) {
    self.config = config
  }
  
  override open func main() {
    if self.isCancelled {
      return
    }

    URLSession.shared.dataTask(with: config.searchUrl()) { (data, response, error) in
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

open class PeliasResponse: APIResponse {
  open let data: Data?
  open let response: URLResponse?
  open let error: NSError?
  open var parsedResponse: PeliasSearchResponse?
  open var parsedError: PeliasError?
  
  public init(data: Data?, response: URLResponse?, error: NSError?) {
    self.data = data
    self.response = response
    self.error = error
    if let dictResponse = parseData(data) {
      if let peliasError = parseErrorFromJSON(dictResponse) {
        self.parsedError = peliasError
        return
      }
      parsedResponse = PeliasSearchResponse(parsedResponse: dictResponse)
    }
  }
  
  fileprivate func parseErrorFromJSON(_ json: NSDictionary) -> PeliasError? {
    //First get the error code
    guard let meta = json["meta"] as? NSDictionary else { return nil }
    guard let status_code = meta["status_code"] as? Int else { return nil }
    
    //Next the message
    guard let results = json["results"] as? NSDictionary else { return nil }
    guard let error = results["error"] as? NSDictionary else { return nil }
    guard let message = error["message"] as? String else { return nil }
    
    let peliasError = PeliasError(code: String(status_code), message: message)
    return peliasError
  }
  
  fileprivate func parseData(_ data: Data?) -> NSDictionary? {
    guard let JSONData = data else { return nil }
    do {
      let JSON = try JSONSerialization.jsonObject(with: JSONData, options:JSONSerialization.ReadingOptions(rawValue: 0))
      guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
        print("Not a Dictionary")
        // put in function
        return nil
      }
      print("JSONDictionary! \(JSONDictionary)")
      return JSONDictionary
    }
    catch let JSONError as NSError {
      print("\(JSONError)")
    }
    return nil
  }
}

public struct PeliasSearchResponse {
  public let parsedResponse: NSDictionary
  
  public init(parsedResponse: NSDictionary) {
    self.parsedResponse = parsedResponse
  }
  
  static func encode(_ response: PeliasSearchResponse) {
    guard let docsPath = HelperClass.path() else { return }
    let personClassObject = HelperClass(response: response)
    
    NSKeyedArchiver.archiveRootObject(personClassObject, toFile: docsPath)
  }
  
  static func decode() -> PeliasSearchResponse? {
    guard let docsPath = HelperClass.path() else { return nil }
    let responseClassObject = NSKeyedUnarchiver.unarchiveObject(withFile: docsPath) as? HelperClass
    
    return responseClassObject?.response
  }
}

public struct PeliasError {
  public let code: String
  public let message: String
  
  public init (code: String, message: String) {
    self.code = code
    self.message = message
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
      guard let parsedResponse = aDecoder.decodeObject(forKey: "parsedResponse") as? NSDictionary else { response = nil; super.init(); return nil }
      
      response = PeliasSearchResponse(parsedResponse: parsedResponse)
      
      super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
      aCoder.encode(response!.parsedResponse, forKey: "parsedResponse")
    }
  }
}
