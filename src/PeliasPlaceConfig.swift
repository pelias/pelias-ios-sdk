//
//  PeliasPlaceConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/16/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasPlaceConfig : PlaceAPIConfigData {
  
  var urlEndpoint = NSURL.init(string: Constants.URL.place, relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!
  var queryItems = [String:NSURLQueryItem]()
  var completionHandler: (PeliasResponse) -> Void
  
  var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem(Constants.API.key, value: key)
      }
    }
  }
  
  var places: [PlaceAPIQueryItem] {
    didSet {
      buildPlaceQueryItem()
    }
  }
  
  init(places: [PlaceAPIQueryItem], completionHandler: (PeliasResponse) -> Void){
    self.places = places
    self.completionHandler = completionHandler
    apiKey = PeliasSearchManager.sharedInstance.apiKey
    
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.key, value: apiKey)
      buildPlaceQueryItem()
    }
  }
  
  mutating func buildPlaceQueryItem() {
    if places.count <= 0 {
      return
    }
    var queryString = ""
    for place in places {
      let addition = "\(place.dataSource.rawValue):\(place.layer.rawValue):\(place.placeId)"
      if queryString.isEmpty {
        queryString = addition
      } else {
        queryString += "&\(addition)"
      }
    }
    
    appendQueryItem(Constants.API.ids, value: queryString)
  }
}

public struct PeliasPlaceQueryItem : PlaceAPIQueryItem {
  var placeId: String
  var dataSource: SearchSource
  var layer: LayerFilter
  
  init(placeId: String, dataSource: SearchSource, layer: LayerFilter) {
    self.placeId = placeId
    self.dataSource = dataSource
    self.layer = layer
  }
}
