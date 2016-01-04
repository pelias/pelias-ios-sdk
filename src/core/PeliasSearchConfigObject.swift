//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasSearchConfig : SearchAPIConfigData {

  var urlEndpoint = NSURL.init(string: "/v1/search", relativeToURL: SearchManager.sharedInstance.baseUrl)!

  var searchText: String{
    didSet {
      appendQueryItem("text", value: searchText)
    }
  }
  
  var completionHandler: (PeliasSearchResponse) -> Void
  
  //Optional Query Params
  var queryItems = [String:NSURLQueryItem]()
  
  var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem("api_key", value: key)
      }
    }
  }
  
  var numberOfResults: Int? {
    didSet {
      if let size = numberOfResults where numberOfResults > 0 {
        appendQueryItem("size", value: String(size))
      }
    }
  }
  
  var boundaryCountry: String? {
    didSet {
      if let country = boundaryCountry where boundaryCountry?.isEmpty == false{
        appendQueryItem("boundary.country", value: country)
      }
    }
  }
  
  var boundaryRect: SearchBoundaryRect? {
    didSet {
      if let rect = boundaryRect {
        appendQueryItem("boundary.rect.min_lat", value: String(rect.minLatLong.latitude))
        appendQueryItem("boundary.rect.min_lon", value: String(rect.minLatLong.longitude))
        appendQueryItem("boundary.rect.max_lat", value: String(rect.maxLatLong.latitude))
        appendQueryItem("boundary.rect.max_lon", value: String(rect.maxLatLong.longitude))
      }
    }
  }
  
  var boundaryCircle: SearchBoundaryCircle? {
    didSet {
      if let circle = boundaryCircle {
        appendQueryItem("boundary.cirle.lat", value: String(circle.center.latitude))
        appendQueryItem("boundary.circle.lon", value: String(circle.center.longitude))
        appendQueryItem("boundary.circle.radius", value: String(circle.radius))
      }
    }
  }
  
  var focusPoint: GeoPoint? {
    didSet {
      if let point = focusPoint {
        appendQueryItem("focus.point.lat", value: String(point.latitude))
        appendQueryItem("focus.point.lon", value: String(point.longitude))
      }
    }
  }
  
  var dataSources: [SearchSource]? {
    didSet {
      if let sources = dataSources where dataSources?.isEmpty == false {
        appendQueryItem("sources", value: SearchSource.dataSourceString(sources))
      }
    }
  }
  
  var layers: [LayerFilter]? {
    didSet {
      if let layerArray = layers where layers?.isEmpty == false {
        appendQueryItem("layers", value: LayerFilter.layerString(layerArray))
      }
    }
  }
  
  init(searchText: String, completionHandler: (PeliasSearchResponse) -> Void){
    self.searchText = searchText
    self.completionHandler = completionHandler
    apiKey = SearchManager.sharedInstance.apiKey
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem("text", value: searchText)
      appendQueryItem("api_key", value: apiKey)
    }
  }
  
  mutating func appendQueryItem(name: String, value: String?) {
    if let queryValue = value where queryValue.isEmpty == false{
      let queryItem = NSURLQueryItem(name: name, value: queryValue)
      queryItems[name] = queryItem;
      
    }
  }
  
  func searchUrl() -> NSURL {
    let urlComponents = NSURLComponents(URL: urlEndpoint, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = Array(queryItems.values)
    return urlComponents!.URL!
  }
}