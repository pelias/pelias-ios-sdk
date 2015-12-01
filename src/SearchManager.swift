//
//  SearchManager.swift
//  PlayMap
//
//  Created by Matt on 11/13/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation
import CoreLocation

public final class SearchManager {
  
  //! Singleton access
  static let sharedInstance = SearchManager()
  
  let operationQueue = NSOperationQueue()
  let locationManager = CLLocationManager()
  
  var authToken: NSString?
  
  private init() {
    operationQueue.maxConcurrentOperationCount = 4
    locationManager.requestWhenInUseAuthorization()
  }
  
  public func performSearch(searchConfig: PeliasSearchConfigObject) -> SearchOperation{
    //TBD - Do error checking to make sure we can actually perform the search
    return executeSearchQuery(searchConfig);
  }

  private func executeSearchQuery(searchConfig: PeliasSearchConfigObject) -> SearchOperation{
    //Build a search operation
    let searchOp = SearchOperation(searchConfig: searchConfig)
    
    //Enqueue search object so it can begin processing
    operationQueue.addOperation(searchOp);
    
    return searchOp;
  }
  
}

public class SearchOperation: NSOperation{
  
  init(searchConfig: PeliasSearchConfigObject) {
    //TBD - Set initial params based off config object
  }
  
  //TBD - Implement main func
  
}