//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to encapsulate request parameters for search requests.
public struct PeliasSearchConfig : SearchAPIConfigData {
  /// Search endpoint on Pelias.
  public var urlEndpoint = URL.init(string: Constants.URL.search, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  /// All the query items that will be used to make the request.
  public var queryItems = [String:URLQueryItem]()
  /// Completion handler invoked on success or failure.
  public var completionHandler: (PeliasResponse) -> Void
  /// Text to search for within components of the location. This value is required to execute a search and will get converted into the appropriate query item.
  public var searchText: String{
    didSet {
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
  /// The number of results to return. This value is optional and will get converted into the appropriate query item. If not specified, Pelias returns 10 results by default.
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
  /// The rectangular boundary to limit results to. This value is optional and will get converted into the appropriate query items. Default is none.
  public var boundaryRect: SearchBoundaryRect? {
    didSet {
      if let rect = boundaryRect {
        appendQueryItem(Constants.Boundary.Rect.minLat, value: String(rect.minLatLong.latitude))
        appendQueryItem(Constants.Boundary.Rect.minLon, value: String(rect.minLatLong.longitude))
        appendQueryItem(Constants.Boundary.Rect.maxLat, value: String(rect.maxLatLong.latitude))
        appendQueryItem(Constants.Boundary.Rect.maxLon, value: String(rect.maxLatLong.longitude))
      }
    }
  }
  /// The circular boundary to limit results to. This value is optional and will get converted into the appropriate query items. Default is none.
  public var boundaryCircle: SearchBoundaryCircle? {
    didSet {
      if let circle = boundaryCircle {
        appendQueryItem(Constants.Boundary.Circle.lat, value: String(circle.center.latitude))
        appendQueryItem(Constants.Boundary.Circle.lon, value: String(circle.center.longitude))
        appendQueryItem(Constants.Boundary.Circle.radius, value: String(circle.radius))
      }
    }
  }
  /// The point to order results by where results closer to this value are returned higher in the list. This value is optional and will get converted into the appropriate query items. Default is none.
  public var focusPoint: GeoPoint? {
    didSet {
      if let point = focusPoint {
        appendQueryItem(Constants.API.focusPointLat, value: String(point.latitude))
        appendQueryItem(Constants.API.focusPointLon, value: String(point.longitude))
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
   Initialize a search config with all the required parameters. This value will get converted into the appropriate query item.

   - parameter searchText: Text to search for within components of the location.
   - parameter completionHandler: The closure to execute when the request suceeds or fails.
   */
  public init(searchText: String, completionHandler: @escaping (PeliasResponse) -> Void) {
    self.searchText = searchText
    self.completionHandler = completionHandler
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.text, value: searchText)
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

