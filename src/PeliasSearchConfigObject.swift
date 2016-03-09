//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasSearchConfig : SearchAPIConfigData {

  public var urlEndpoint = NSURL.init(string: Constants.URL.search, relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!

  public var searchText: String{
    didSet {
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
  
  public var queryItems = [String:NSURLQueryItem]()
  
  public var completionHandler: (PeliasResponse) -> Void
  
  public var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem(Constants.API.key, value: key)
      }
    }
  }
  
  //Optional Query Params
  
  public var numberOfResults: Int? {
    didSet {
      if let size = numberOfResults where numberOfResults > 0 {
        appendQueryItem(Constants.API.size, value: String(size))
      }
    }
  }
  
  public var boundaryCountry: String? {
    didSet {
      if let country = boundaryCountry where boundaryCountry?.isEmpty == false{
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
      if let sources = dataSources where dataSources?.isEmpty == false {
        appendQueryItem(Constants.API.sources, value: SearchSource.dataSourceString(sources))
      }
    }
  }
  
  public var layers: [LayerFilter]? {
    didSet {
      if let layerArray = layers where layers?.isEmpty == false {
        appendQueryItem(Constants.API.layers, value: LayerFilter.layerString(layerArray))
      }
    }
  }
  
  public init(searchText: String, completionHandler: (PeliasResponse) -> Void){
    self.searchText = searchText
    self.completionHandler = completionHandler
    apiKey = PeliasSearchManager.sharedInstance.apiKey
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.text, value: searchText)
      appendQueryItem(Constants.API.key, value: apiKey)
    }
  }
}