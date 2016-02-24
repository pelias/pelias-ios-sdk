//
//  PeliasReverseGeoConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/27/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasReverseConfig : ReverseAPIConfigData {
  var urlEndpoint = NSURL.init(string: Constants.URL.reverse, relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!
  
  var apiKey: String? {
    didSet {
      if let key = apiKey where apiKey?.isEmpty == false {
        appendQueryItem(Constants.API.key, value: key)
      }
    }
  }
  
  var queryItems = [String:NSURLQueryItem]()
  
  var completionHandler: (PeliasResponse) -> Void
  
  var point: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
    }
  }

  //Optional Query Params

  var numberOfResults: Int? {
    didSet {
      if let size = numberOfResults where numberOfResults > 0 {
        appendQueryItem(Constants.API.size, value: String(size))
      }
    }
  }
  
  var boundaryCountry: String? {
    didSet {
      if let country = boundaryCountry where boundaryCountry?.isEmpty == false{
        appendQueryItem(Constants.Boundary.country, value: country)
      }
    }
  }
  
  var dataSources: [SearchSource]? {
    didSet {
      if let sources = dataSources where dataSources?.isEmpty == false {
        appendQueryItem(Constants.API.sources, value: SearchSource.dataSourceString(sources))
      }
    }
  }
  
  var layers: [LayerFilter]? {
    didSet {
      if let layerArray = layers where layers?.isEmpty == false {
        appendQueryItem(Constants.API.layers, value: LayerFilter.layerString(layerArray))
      }
    }
  }
  init(point: GeoPoint, completionHandler: (PeliasResponse) -> Void){
    self.point = point
    self.completionHandler = completionHandler
    apiKey = PeliasSearchManager.sharedInstance.apiKey
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
      appendQueryItem(Constants.API.key, value: apiKey)
    }
  }
}
