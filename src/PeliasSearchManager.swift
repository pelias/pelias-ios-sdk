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
  private let operationQueue = NSOperationQueue()
  private let autocompleteOperationQueue = NSOperationQueue()
  private var autocompleteQueryTimer: NSTimer?
  internal var queuedAutocompleteOp: PeliasOperation?
  public var autocompleteTimeDelay: Double = 0.0 //In seconds
  public var apiKey: String?
  public var baseUrl: NSURL
  
  private init() {
    operationQueue.maxConcurrentOperationCount = 4
    autocompleteOperationQueue.maxConcurrentOperationCount = 1
    baseUrl = NSURL.init(string: Constants.URL.base)! // Force the unwrap because we must have a base URL to operate
  }
  
  public func performSearch(config: PeliasSearchConfig) -> PeliasOperation {
    return executeOperation(config);
  }
  
  public func reverseGeocode(config: PeliasReverseConfig) -> PeliasOperation {
    return executeOperation(config);
  }
  
  public func autocompleteQuery(config: PeliasAutocompleteConfig) -> PeliasOperation {
    
    return executeAutocompleteOperation(config)
  }
  
  public func placeQuery(config: PeliasPlaceConfig) -> PeliasOperation {
    return executeOperation(config)
  }
  
  public func cancelOperations() {
    self.operationQueue.cancelAllOperations()
    self.autocompleteOperationQueue.cancelAllOperations()
  }
  
  private func executeOperation(config: APIConfigData) -> PeliasOperation {
    //Build a operation
    let searchOp = PeliasOperation(config: config)
    
    //Enqueue search object so it can begin processing
    operationQueue.addOperation(searchOp)
    
    return searchOp;
  }
  
  private func executeAutocompleteOperation(config: PeliasAutocompleteConfig) -> PeliasOperation {
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
  
  @objc private func autocompleteTimerExecute() {
    //Check to see if we have an operation waiting for us
    if let operation = queuedAutocompleteOp {
      //We have one! Lets fire it, and then create a new timer that will fire once in whatever delay there is from now
      print("Engaging Rate limiter")
      autocompleteOperationQueue.addOperation(operation)
      queuedAutocompleteOp = nil
      autocompleteQueryTimer = NSTimer.scheduledTimerWithTimeInterval(autocompleteTimeDelay, target: self, selector: #selector(PeliasSearchManager.autocompleteTimerExecute), userInfo: nil, repeats: false)
    }
    else {
      //We don't have one! Set it to nil so we come back into this function
      autocompleteQueryTimer = nil
    }
  }
}

public class PeliasOperation: NSOperation {
  
  let config: APIConfigData
  
  public init(config: APIConfigData) {
    self.config = config
  }
  
  override public func main() {
    if self.cancelled {
      return
    }
    NSURLSession.sharedSession().dataTaskWithURL(config.searchUrl()) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      if self.cancelled {
        return
      }
      let searchResponse = PeliasResponse(data: data, response: response, error: error)
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        if self.cancelled {
          return
        }
        self.config.completionHandler(searchResponse)
      })
    }.resume()
  }
}

public class PeliasResponse: APIResponse {
  public let data: NSData?
  public let response: NSURLResponse?
  public let error: NSError?
  public var parsedResponse: PeliasSearchResponse?
  public var parsedError: PeliasError?
  
  public init(data: NSData?, response: NSURLResponse?, error: NSError?) {
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
  
  private func parseErrorFromJSON(json: NSDictionary) -> PeliasError? {
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
  
  private func parseData(data: NSData?) -> NSDictionary? {
    guard let JSONData = data else { return nil }
    do {
      let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData, options:NSJSONReadingOptions(rawValue: 0))
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
  
  static func encode(response: PeliasSearchResponse) {
    let personClassObject = HelperClass(response: response)
    
    NSKeyedArchiver.archiveRootObject(personClassObject, toFile: HelperClass.path())
  }
  
  static func decode() -> PeliasSearchResponse? {
    let responseClassObject = NSKeyedUnarchiver.unarchiveObjectWithFile(HelperClass.path()) as? HelperClass
    
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
  public class HelperClass: NSObject, NSCoding {
    
    public var response: PeliasSearchResponse?
    
    public init(response: PeliasSearchResponse) {
      self.response = response
      super.init()
    }
    
    class func path() -> String {
      let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
      let path = documentsPath?.stringByAppendingString("/Response")
      return path!
    }
    
    public required init?(coder aDecoder: NSCoder) {
      guard let parsedResponse = aDecoder.decodeObjectForKey("parsedResponse") as? NSDictionary else { response = nil; super.init(); return nil }
      
      response = PeliasSearchResponse(parsedResponse: parsedResponse)
      
      super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
      aCoder.encodeObject(response!.parsedResponse, forKey: "parsedResponse")
    }
  }
}
