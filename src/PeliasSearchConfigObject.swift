//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
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


public struct PeliasSearchConfig : SearchAPIConfigData {

  public var urlEndpoint = URL.init(string: Constants.URL.search, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!

  public var searchText: String{
    didSet {
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
  
  public var queryItems = [String:URLQueryItem]()
  
  public var completionHandler: (PeliasResponse) -> Void
  
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
  
  public var boundaryCircle: SearchBoundaryCircle? {
    didSet {
      if let circle = boundaryCircle {
        appendQueryItem(Constants.Boundary.Circle.lat, value: String(circle.center.latitude))
        appendQueryItem(Constants.Boundary.Circle.lon, value: String(circle.center.longitude))
        appendQueryItem(Constants.Boundary.Circle.radius, value: String(circle.radius))
      }
    }
  }
  
  public var focusPoint: GeoPoint? {
    didSet {
      if let point = focusPoint {
        appendQueryItem(Constants.API.focusPointLat, value: String(point.latitude))
        appendQueryItem(Constants.API.focusPointLon, value: String(point.longitude))
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
  
  public init(searchText: String, completionHandler: @escaping (PeliasResponse) -> Void) {
    self.searchText = searchText
    self.completionHandler = completionHandler
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
}
