//
//  PeliasPlaceConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/16/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasPlaceConfig : PlaceAPIConfigData {
  
  public var urlEndpoint = URL.init(string: Constants.URL.place, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  public var queryItems = [String:URLQueryItem]()
  public var completionHandler: (PeliasResponse) -> Void
  
  public var places: [PlaceAPIQueryItem] {
    didSet {
      buildPlaceQueryItem()
    }
  }
  
  public init(places: [PlaceAPIQueryItem], completionHandler: @escaping (PeliasResponse) -> Void){
    self.places = places
    self.completionHandler = completionHandler

    defer {
      //didSet will not fire because self is not setup so we have to do this manually
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
  public var placeId: String
  public var dataSource: SearchSource
  public var layer: LayerFilter
  
  public init(placeId: String, dataSource: SearchSource, layer: LayerFilter) {
    self.placeId = placeId
    self.dataSource = dataSource
    self.layer = layer
  }
}
