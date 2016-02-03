//
//  PeliasReverseGeoConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/27/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasReverseConfig : ReverseAPIConfigData {
  var urlEndpoint = NSURL.init(string: "/v1/reverse", relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!
  
  var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem("api_key", value: key)
      }
    }
  }
  
  var queryItems = [String:NSURLQueryItem]()
  
  var completionHandler: (PeliasResponse) -> Void
  
  var point: GeoPoint {
    didSet {
      appendQueryItem("point.lat", value: String(point.latitude))
      appendQueryItem("point.lon", value: String(point.longitude))
    }
  }

  //Optional Query Params

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
  init(point: GeoPoint, completionHandler: (PeliasResponse) -> Void){
    self.point = point
    self.completionHandler = completionHandler
    apiKey = PeliasSearchManager.sharedInstance.apiKey
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem("point.lat", value: String(point.latitude))
      appendQueryItem("point.lon", value: String(point.longitude))
      appendQueryItem("api_key", value: apiKey)
    }
  }
}
