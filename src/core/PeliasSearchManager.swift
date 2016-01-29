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
    //TODO: Implement Rate Limiting
    return executeOperation(config)
  }
  
  private func executeOperation(config: APIConfigData) -> PeliasOperation {
    //Build a operation
    let searchOp = PeliasOperation(config: config)
    
    //Enqueue search object so it can begin processing
    operationQueue.addOperation(searchOp);
    
    return searchOp;
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