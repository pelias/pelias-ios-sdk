//
//  PeliasAutocompleteConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/28/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasAutocompleteConfig : AutocompleteAPIConfigData {
  
  var focusPoint: GeoPoint {
    didSet {
      appendQueryItem("focus.point.lat", value: String(focusPoint.latitude))
      appendQueryItem("focus.point.lon", value: String(focusPoint.longitude))
    }
  }
  var urlEndpoint = NSURL.init(string: "/v1/autocomplete", relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!
  
  var searchText: String{
    didSet {
      appendQueryItem("text", value: searchText)
    }
  }
  
  var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem("api_key", value: key)
      }
    }
  }
  
  var queryItems = [String:NSURLQueryItem]()
  
  var completionHandler: (PeliasResponse) -> Void
  
  init(searchText: String, focusPoint: GeoPoint, completionHandler: (PeliasResponse) -> Void){
    self.searchText = searchText
    self.completionHandler = completionHandler
    self.focusPoint = focusPoint
    apiKey = PeliasSearchManager.sharedInstance.apiKey
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem("text", value: searchText)
      appendQueryItem("api_key", value: apiKey)
      appendQueryItem("focus.point.lat", value: String(focusPoint.latitude))
      appendQueryItem("focus.point.lon", value: String(focusPoint.longitude))
    }
  }
}