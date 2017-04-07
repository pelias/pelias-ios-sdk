//
//  PeliasPlaceConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/16/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasPlaceConfig : PlaceAPIConfigData {
  
  public var urlEndpoint = URL.init(string: Constants.URL.place, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  public var queryItems = [String:URLQueryItem]()
  public var completionHandler: (PeliasResponse) -> Void
  
  public var gids: [String] {
    didSet {
      buildPlaceQueryItem()
    }
  }
  
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
