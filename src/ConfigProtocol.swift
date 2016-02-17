//
//  ConfigProtocol.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/2/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

struct SearchBoundaryRect : Equatable {
  let minLatLong: GeoPoint
  let maxLatLong: GeoPoint
  
  init(minLatLong: GeoPoint, maxLatLong: GeoPoint) {
    self.minLatLong = minLatLong
    self.maxLatLong = maxLatLong
  }
}

func ==(lhs: SearchBoundaryRect, rhs: SearchBoundaryRect) -> Bool {
  return ((lhs.minLatLong == rhs.minLatLong) && (lhs.maxLatLong == rhs.maxLatLong))
}

struct SearchBoundaryCircle : Equatable {
  let center: GeoPoint
  let radius: Double
  
  init(center: GeoPoint, radius: Double) {
    self.center = center
    self.radius = radius
  }
}

func ==(lhs: SearchBoundaryCircle, rhs: SearchBoundaryCircle) -> Bool {
  return (lhs.radius == rhs.radius && lhs.center == rhs.center)
}

struct GeoPoint : Equatable {
  let latitude: Double
  let longitude: Double
  
  init(latitude: Double, longitude: Double) {
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
  case GeoNames = "gn"
  
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
  var queryItems: [String:NSURLQueryItem] { get set }
  var completionHandler: (PeliasResponse) -> Void { get set }
  
  func searchUrl() -> NSURL
  mutating func appendQueryItem(name: String, value: String?)
}

extension APIConfigData {
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

protocol GenericSearchAPIConfigData : APIConfigData {
  var searchText: String { get set }
}

protocol AutocompleteAPIConfigData: GenericSearchAPIConfigData {
  var focusPoint: GeoPoint { get set }
}

protocol SearchAPIConfigData : GenericSearchAPIConfigData {
  
  var focusPoint: GeoPoint? { get set }
  var numberOfResults: Int? { get set }
  var boundaryCountry: String? { get set }
  var boundaryRect: SearchBoundaryRect? { get set }
  var boundaryCircle: SearchBoundaryCircle? { get set }
  var dataSources: [SearchSource]? { get set }
  var layers: [LayerFilter]? { get set }
}

protocol ReverseAPIConfigData: APIConfigData {
  var point: GeoPoint { get set }
  var numberOfResults: Int? { get set }
  var dataSources: [SearchSource]? { get set }
  var boundaryCountry: String? { get set }
  var layers: [LayerFilter]? { get set }
}

protocol PlaceAPIConfigData: APIConfigData {
  var places: [PlaceAPIQueryItem] { get set }
}

protocol PlaceAPIQueryItem {
  var placeId: String { get set }
  var dataSource: SearchSource { get set }
  var layer: LayerFilter { get set }
}

protocol APIResponse {
  var data: NSData? { get }
  var response: NSURLResponse? { get }
  var error: NSError? { get }
}