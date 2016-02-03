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
  static let sharedInstance = PeliasSearchManager()
  private let operationQueue = NSOperationQueue()
  private let autocompleteOperationQueue = NSOperationQueue()
  private var autocompleteQueryTimer: NSTimer?
  private var queuedAutocompleteOp: PeliasOperation?
  public var autocompleteTimeDelay: Double = 0.0 //In seconds
  var apiKey: String?
  var baseUrl: NSURL
  
  private init() {
    operationQueue.maxConcurrentOperationCount = 4
    autocompleteOperationQueue.maxConcurrentOperationCount = 1
    baseUrl = NSURL.init(string: "https://search.mapzen.com")! // Force the unwrap because we must have a base URL to operate
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
      autocompleteQueryTimer = NSTimer.scheduledTimerWithTimeInterval(autocompleteTimeDelay, target: self, selector: "autocompleteTimerExecute", userInfo: nil, repeats: false)
    }
    else {
      //We don't have one! Set it to nil so we come back into this function
      autocompleteQueryTimer = nil
    }
  }
}

public class PeliasOperation: NSOperation {
  
  let config: APIConfigData
  
  init(config: APIConfigData) {
    self.config = config
  }
  
  override public func main() {
    NSURLSession.sharedSession().dataTaskWithURL(config.searchUrl()) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      let searchResponse = PeliasResponse(data: data, response: response, error: error)
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.config.completionHandler(searchResponse)
      })
    }.resume()
  }
}

public class PeliasResponse: APIResponse {
  let data: NSData?
  let response: NSURLResponse?
  let error: NSError?
  var parsedResponse: NSDictionary?
  
  init(data: NSData?, response: NSURLResponse?, error: NSError?) {
    self.data = data
    self.response = response
    self.error = error
    parsedResponse = parseData(data)
  }
  
  private func parseData(data: NSData?) -> NSDictionary? {
    let JSONData = data!
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