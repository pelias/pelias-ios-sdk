//
//  SearchManager.swift
//  PlayMap
//
//  Created by Matt on 11/13/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public final class SearchManager {
  
  //! Singleton access
  static let sharedInstance = SearchManager()
  
  private let operationQueue = NSOperationQueue()
  
  var apiKey: String?
  
  var baseUrl: NSURL
  
  private init() {
    operationQueue.maxConcurrentOperationCount = 4
    baseUrl = NSURL.init(string: "https://search.mapzen.com")! // Force the unwrap because we must have a base URL to operate
  }
  
  public func performSearch(searchConfig: PeliasSearchConfig) -> SearchOperation{
    //TBD - Do error checking to make sure we can actually perform the search
    return executeSearchQuery(searchConfig);
  }

  private func executeSearchQuery(searchConfig: PeliasSearchConfig) -> SearchOperation{
    //Build a search operation
    let searchOp = SearchOperation(searchConfig: searchConfig)
    
    //Enqueue search object so it can begin processing
    operationQueue.addOperation(searchOp);
    
    return searchOp;
  }
  
}

public class SearchOperation: NSOperation{
  
  let searchConfig: PeliasSearchConfig
  
  init(searchConfig: PeliasSearchConfig) {
    self.searchConfig = searchConfig
  }
  
  override public func main() {
    NSURLSession.sharedSession().dataTaskWithURL(searchConfig.searchUrl()) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      let searchResponse = PeliasSearchResponse(data: data, response: response, error: error)
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.searchConfig.completionHandler(searchResponse)
      })
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.searchConfig.completionHandler(searchResponse)
      })
    }.resume()
  }
}