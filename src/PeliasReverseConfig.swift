//
//  PeliasReverseGeoConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/27/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public struct PeliasReverseConfig : ReverseAPIConfigData {
  public var urlEndpoint = URL.init(string: Constants.URL.reverse, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  
  public var queryItems = [String:URLQueryItem]()
  
  public var completionHandler: (PeliasResponse) -> Void
  
  public var point: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
    }
  }

  //Optional Query Params

  public var numberOfResults: Int? {
    didSet {
      if let size = numberOfResults, numberOfResults > 0 {
        appendQueryItem(Constants.API.size, value: String(size))
      }
    }
  }
  
  public var boundaryCountry: String? {
    didSet {
      if let country = boundaryCountry, boundaryCountry?.isEmpty == false {
        appendQueryItem(Constants.Boundary.country, value: country)
      }
    }
  }
  
  public var dataSources: [SearchSource]? {
    didSet {
      if let sources = dataSources, dataSources?.isEmpty == false {
        appendQueryItem(Constants.API.sources, value: SearchSource.dataSourceString(sources))
      }
    }
  }
  
  public var layers: [LayerFilter]? {
    didSet {
      if let layerArray = layers, layers?.isEmpty == false {
        appendQueryItem(Constants.API.layers, value: LayerFilter.layerString(layerArray))
      }
    }
  }
  
  public init(point: GeoPoint, completionHandler: @escaping (PeliasResponse) -> Void) {
    self.point = point
    self.completionHandler = completionHandler
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
    }
  }
}
