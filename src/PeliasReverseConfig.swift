//
//  PeliasReverseGeoConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/27/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to encapsulate request parameters for reverse geo requests.
public struct PeliasReverseConfig : ReverseAPIConfigData {
  /// Reverse geo endpoint on Pelias.
  public var urlEndpoint = URL.init(string: Constants.URL.reverse, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  /// All the query items that will be used to make the request.
  public var queryItems = [String:URLQueryItem]()
  /// Completion handler invoked on success or failure.
  public var completionHandler: (PeliasResponse) -> Void
  /// The point to reverse geocode. This value is required and will get converted into the appropriate query items.
  public var point: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
    }
  }
  /// The number of results to return. This value is optional and will get converted into the appropriate query item. Default value if none defined is 10.
  public var numberOfResults: Int? {
    didSet {
      if let size = numberOfResults, numberOfResults > 0 {
        appendQueryItem(Constants.API.size, value: String(size))
      }
    }
  }
  /// The boundary country (in ISO-3166 alpha-2 or alpha-3 format) to limit results by. This value is optional and will get converted into the appropriate query item. Default is none.
  public var boundaryCountry: String? {
    didSet {
      if let country = boundaryCountry, boundaryCountry?.isEmpty == false {
        appendQueryItem(Constants.Boundary.country, value: country)
      }
    }
  }
  /// Sources to fetch data from. This value is optional and will get converted into the appropriate query item. Default is all sources.
  public var dataSources: [SearchSource]? {
    didSet {
      if let sources = dataSources, dataSources?.isEmpty == false {
        appendQueryItem(Constants.API.sources, value: SearchSource.dataSourceString(sources))
      }
    }
  }
  /// Layers to fetch sources from. This value is optional and will get converted into the appropriate query item. Default is all sources.
  public var layers: [LayerFilter]? {
    didSet {
      if let layerArray = layers, layers?.isEmpty == false {
        appendQueryItem(Constants.API.layers, value: LayerFilter.layerString(layerArray))
      }
    }
  }
  /**
   Initialize a reverse config with all the required parameters.
   
   - parameter point: The point to reverse geocode.
   - parameter completionHandler: The closure to execute when the request suceeds or fails.
   */
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
