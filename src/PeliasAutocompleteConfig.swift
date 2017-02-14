//
//  PeliasAutocompleteConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/28/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasAutocompleteConfig : AutocompleteAPIConfigData {
  
  public var focusPoint: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.focusPointLat, value: String(focusPoint.latitude))
      appendQueryItem(Constants.API.focusPointLon, value: String(focusPoint.longitude))
    }
  }
  public var urlEndpoint = URL.init(string: Constants.URL.autocomplete, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  
  public var searchText: String{
    didSet {
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
  
  public var queryItems = [String:URLQueryItem]()
  
  public var completionHandler: (PeliasResponse) -> Void
  
  public init(searchText: String, focusPoint: GeoPoint, completionHandler: @escaping (PeliasResponse) -> Void){
    self.searchText = searchText
    self.completionHandler = completionHandler
    self.focusPoint = focusPoint
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.text, value: searchText)
      appendQueryItem(Constants.API.focusPointLat, value: String(focusPoint.latitude))
      appendQueryItem(Constants.API.focusPointLon, value: String(focusPoint.longitude))
    }
  }
}
