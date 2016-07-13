//
//  ConfigProtocol.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/2/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct SearchBoundaryRect : Equatable {
  public let minLatLong: GeoPoint
  public let maxLatLong: GeoPoint
  
  public init(minLatLong: GeoPoint, maxLatLong: GeoPoint) {
    self.minLatLong = minLatLong
    self.maxLatLong = maxLatLong
  }
}

public func ==(lhs: SearchBoundaryRect, rhs: SearchBoundaryRect) -> Bool {
  return ((lhs.minLatLong == rhs.minLatLong) && (lhs.maxLatLong == rhs.maxLatLong))
}

public struct SearchBoundaryCircle : Equatable {
  let center: GeoPoint
  let radius: Double
  
  public init(center: GeoPoint, radius: Double) {
    self.center = center
    self.radius = radius
  }
}

public func ==(lhs: SearchBoundaryCircle, rhs: SearchBoundaryCircle) -> Bool {
  return (lhs.radius == rhs.radius && lhs.center == rhs.center)
}

public struct GeoPoint : Equatable {
  let latitude: Double
  let longitude: Double
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

public func ==(lhs: GeoPoint, rhs: GeoPoint) -> Bool {
  return ((lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude))
}

public enum SearchSource: String {
  case OpenStreetMap = "osm"
  case OpenAddresses = "oa"
  case Quattroshapes = "qs"
  case GeoNames = "gn"
  
  public static func dataSourceString(sourceList: [SearchSource]) -> String {
    return sourceList.map{$0.rawValue}.joinWithSeparator(",")
  }
}

public enum LayerFilter: String {
  case venue, address, country, region, county, locality, localadmin, neighbourhood, coarse
  
  public static func layerString(layers: [LayerFilter]) -> String {
    return layers.map{$0.rawValue}.joinWithSeparator(",")
  }
}

public protocol APIConfigData {
  var urlEndpoint: NSURL { get }
  var apiKey: String? { get }
  var queryItems: [String:NSURLQueryItem] { get set }
  var completionHandler: (PeliasResponse) -> Void { get set }
  
  func searchUrl() -> NSURL
  mutating func appendQueryItem(name: String, value: String?)
}

public extension APIConfigData {
  mutating public func appendQueryItem(name: String, value: String?) {
    if let queryValue = value where queryValue.isEmpty == false{
      let queryItem = NSURLQueryItem(name: name, value: queryValue)
      queryItems[name] = queryItem;
      
    }
  }
  
  public func searchUrl() -> NSURL {
    let urlComponents = NSURLComponents(URL: urlEndpoint, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = Array(queryItems.values)
    return urlComponents!.URL!
  }
}

public protocol GenericSearchAPIConfigData : APIConfigData {
  var searchText: String { get set }
}

public protocol AutocompleteAPIConfigData: GenericSearchAPIConfigData {
  var focusPoint: GeoPoint { get set }
}

public protocol SearchAPIConfigData : GenericSearchAPIConfigData {
  
  var focusPoint: GeoPoint? { get set }
  var numberOfResults: Int? { get set }
  var boundaryCountry: String? { get set }
  var boundaryRect: SearchBoundaryRect? { get set }
  var boundaryCircle: SearchBoundaryCircle? { get set }
  var dataSources: [SearchSource]? { get set }
  var layers: [LayerFilter]? { get set }
}

public protocol ReverseAPIConfigData: APIConfigData {
  var point: GeoPoint { get set }
  var numberOfResults: Int? { get set }
  var dataSources: [SearchSource]? { get set }
  var boundaryCountry: String? { get set }
  var layers: [LayerFilter]? { get set }
}

public protocol PlaceAPIConfigData: APIConfigData {
  var places: [PlaceAPIQueryItem] { get set }
}

public protocol PlaceAPIQueryItem {
  var placeId: String { get set }
  var dataSource: SearchSource { get set }
  var layer: LayerFilter { get set }
}

public protocol APIResponse {
  var data: NSData? { get }
  var response: NSURLResponse? { get }
  var error: NSError? { get }
}