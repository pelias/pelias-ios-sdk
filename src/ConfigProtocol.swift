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
  
  public static func dataSourceString(_ sourceList: [SearchSource]) -> String {
    return sourceList.map{$0.rawValue}.joined(separator: ",")
  }
}

public enum LayerFilter: String {
  case venue, address, country, region, county, locality, localadmin, neighbourhood, coarse
  
  public static func layerString(_ layers: [LayerFilter]) -> String {
    return layers.map{$0.rawValue}.joined(separator: ",")
  }
}

public protocol APIConfigData {
  var urlEndpoint: URL { get }
  var queryItems: [String:URLQueryItem] { get set }
  var completionHandler: (PeliasResponse) -> Void { get set }
  
  func searchUrl() -> URL
  mutating func appendQueryItem(_ name: String, value: String?)
}

public extension APIConfigData {
  mutating public func appendQueryItem(_ name: String, value: String?) {
    if let queryValue = value, queryValue.isEmpty == false{
      let queryItem = URLQueryItem(name: name, value: queryValue)
      queryItems[name] = queryItem;
      
    }
  }
  
  public func searchUrl() -> URL {
    var urlComponents = URLComponents(url: urlEndpoint, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = Array(queryItems.values)
    return urlComponents!.url!
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
  var data: Data? { get }
  var response: URLResponse? { get }
  var error: NSError? { get }
}
