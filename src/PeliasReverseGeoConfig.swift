//
//  PeliasReverseGeoConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/27/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasReverseConfig : ReverseAPIConfigData {
  public var urlEndpoint = NSURL.init(string: Constants.URL.reverse, relativeToURL: PeliasSearchManager.sharedInstance.baseUrl)!
  
  public var queryItems = [String:NSURLQueryItem]()
  
  public var completionHandler: (PeliasResponse) -> Void
  
  public var point: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
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
  
  public init(point: GeoPoint, completionHandler: (PeliasResponse) -> Void){
    self.point = point
    self.completionHandler = completionHandler
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.pointLat, value: String(point.latitude))
      appendQueryItem(Constants.API.pointLon, value: String(point.longitude))
    }
  }
}
