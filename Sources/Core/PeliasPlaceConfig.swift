//
//  PeliasPlaceConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/16/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to encapsulate request parameters for place requests.
public struct PeliasPlaceConfig : PlaceAPIConfigData {
  /// Place endpoint on Pelias.
  public var urlEndpoint = URL.init(string: Constants.URL.place, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  /// All the query items that will be used to make the request.
  public var queryItems = [String:URLQueryItem]()
  /// Completion handler invoked on success or failure.
  public var completionHandler: (PeliasResponse) -> Void
  /// The place gids to fetch info for. These values will get converted into the appropriate query items.
  public var gids: [String] {
    didSet {
      buildPlaceQueryItem()
    }
  }
  /**
   Initialize a place config with all the required parameters. These values will get converted into the appropriate query items.

   - parameter gids: The place gids to request info for.
   - parameter completionHandler: The closure to execute when the request suceeds or fails.
   */
  public init(gids: [String], completionHandler: @escaping (PeliasResponse) -> Void) {
    self.gids = gids
    self.completionHandler = completionHandler

    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      buildPlaceQueryItem()
    }
  }
  
  mutating func buildPlaceQueryItem() {
    if gids.count <= 0 {
      return
    }
    var queryString = ""
    for gid in gids {
      if queryString.isEmpty {
        queryString = gid
      } else {
        queryString += ",\(gid)"
      }
    }
    
    appendQueryItem(Constants.API.ids, value: queryString)
  }
}
