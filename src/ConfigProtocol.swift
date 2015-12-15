//
//  ConfigProtocol.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/2/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

struct SearchBoundaryRect : Equatable{
  var minLatLong: GeoPoint
  var maxLatLong: GeoPoint
  
  init(minLatLong: GeoPoint, maxLatLong: GeoPoint){
    self.minLatLong = minLatLong
    self.maxLatLong = maxLatLong
  }
}

func ==(lhs: SearchBoundaryRect, rhs: SearchBoundaryRect) -> Bool {
  return ((lhs.minLatLong == rhs.minLatLong) && (lhs.maxLatLong == rhs.maxLatLong))
}

struct SearchBoundaryCircle : Equatable {
  var center: GeoPoint
  var radius: Float
  
  init(center: GeoPoint, radius: Float){
    self.center = center
    self.radius = radius
  }
}

func ==(lhs: SearchBoundaryCircle, rhs: SearchBoundaryCircle) -> Bool {
  return (lhs.radius == rhs.radius && lhs.center == rhs.center)
}

struct GeoPoint : Equatable {
  var latitude: Float
  var longitude: Float
  
  init(latitude: Float, longitude: Float){
    self.latitude = latitude
    self.longitude = longitude
  }
}

func ==(lhs: GeoPoint, rhs: GeoPoint) -> Bool {
  return ((lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude))
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

protocol APIResponse {
  var data: NSData? { get }
  var response: NSURLResponse? { get }
  var error: NSError? { get }
}