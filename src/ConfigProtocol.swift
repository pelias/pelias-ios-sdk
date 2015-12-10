//
//  ConfigProtocol.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/2/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

struct SearchBoundaryRect {
  var minLatLong: GeoPoint
  var maxLatLong: GeoPoint
}

struct SearchBoundaryCircle {
  var center: GeoPoint
  var radius: Float
}

struct GeoPoint {
  var latitude: Float
  var longitude: Float
}

enum SearchSource: String {
  case OpenStreetMap = "osm"
  case OpenAddresses = "oa"
  case Quattroshapes = "qs"
  case GeoNames = "ga"
  
  static func dataSourceString(sourceList: [SearchSource]) -> String {
    return sourceList.map{$0.rawValue}.joinWithSeparator(",")
  }
}

enum LayerFilter: String {
  case venue, address, country, region, county, locality, localadmin, neighbourhood, coarse
  
  static func layerString(layers: [LayerFilter]) -> String {
    return layers.map{$0.rawValue}.joinWithSeparator(",")
  }
}

protocol APIConfigData {
  var urlEndpoint: NSURL { get }
  var apiKey: String? { get }
  
  func searchUrl() -> NSURL
}

protocol SearchAPIConfigData : APIConfigData {
  var searchText: String { get set }
  
  var numberOfResults: Int? { get set }
  var boundaryCountry: String? { get set }
  var boundaryRect: SearchBoundaryRect? { get set }
  var boundaryCircle: SearchBoundaryCircle? { get set }
  var focusPoint: GeoPoint? { get set }
  var dataSources: [SearchSource]? { get set }
  var layers: [LayerFilter]? { get set }
  var completionHandler: (PeliasSearchResponse) -> Void { get set }
}