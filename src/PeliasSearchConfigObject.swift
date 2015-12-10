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
      appendQueryItem("api_key", value: apiKey)
    }
  }
  
  var numberOfResults: Int? {
    didSet {
      appendQueryItem("size", value: String(numberOfResults))
    }
  }
  
  var boundaryCountry: String? {
    didSet {
      appendQueryItem("boundary.country", value: apiKey)
    }
  }
  
  var boundaryRect: SearchBoundaryRect? {
    didSet {
      appendQueryItem("boundary.rect.min_lat", value: String(boundaryRect?.minLatLong.latitude))
      appendQueryItem("boundary.rect.min_lon", value: String(boundaryRect?.minLatLong.longitude))
      appendQueryItem("boundary.rect.max_lat", value: String(boundaryRect?.maxLatLong.latitude))
      appendQueryItem("boundary.rect.max_lon", value: String(boundaryRect?.maxLatLong.longitude))
    }
  }
  
  var boundaryCircle: SearchBoundaryCircle? {
    didSet {
      appendQueryItem("boundary.cirle.lat", value: String(boundaryCircle?.center.latitude))
      appendQueryItem("boundary.circle.lon", value: String(boundaryCircle?.center.longitude))
      appendQueryItem("boundary.circle.radius", value: String(boundaryCircle?.radius))
    }
  }
  
  var focusPoint: GeoPoint? {
    didSet {
      appendQueryItem("focus.point.lat", value: String(focusPoint?.latitude))
      appendQueryItem("focus.point.lon", value: String(focusPoint?.longitude))
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