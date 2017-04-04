//
//  ConfigProtocol.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/2/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to represent a search request's rectangular boundary.
public struct SearchBoundaryRect : Equatable {
  /// Minimum latitude value.
  public let minLatLong: GeoPoint
  /// Maximum latitude value.
  public let maxLatLong: GeoPoint
  /**
   Initialize a structure with given min and max points.
   - parameter minLatLong: Minimum latitude value.
   - parameter maxLatLong: Maximum latitude value.
   */
  public init(minLatLong: GeoPoint, maxLatLong: GeoPoint) {
    self.minLatLong = minLatLong
    self.maxLatLong = maxLatLong
  }
}

public func ==(lhs: SearchBoundaryRect, rhs: SearchBoundaryRect) -> Bool {
  return ((lhs.minLatLong == rhs.minLatLong) && (lhs.maxLatLong == rhs.maxLatLong))
}

/// Structure used to represent a search request's circular boundary.
public struct SearchBoundaryCircle : Equatable {
  /// Center point.
  let center: GeoPoint
  /// Radius in kilometers.
  let radius: Double
  /**
   Initialize a structure with given center and radius.
   - parameter center: Center point.
   - parameter radius: Radius in kilometers.
   */
  public init(center: GeoPoint, radius: Double) {
    self.center = center
    self.radius = radius
  }
}

public func ==(lhs: SearchBoundaryCircle, rhs: SearchBoundaryCircle) -> Bool {
  return (lhs.radius == rhs.radius && lhs.center == rhs.center)
}

/// Structure used to represent a coordinate point.
public struct GeoPoint : Equatable {
  /// Latitude.
  let latitude: Double
  /// Longitude.
  let longitude: Double
  /**
   Initialize a structure with given latitude and longitude.
   - parameter latitude: Latitude.
   - parameter longitude: Longitude.
   */
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

public func ==(lhs: GeoPoint, rhs: GeoPoint) -> Bool {
  return ((lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude))
}

/// Represents possible sources for search results to be returned from.
public enum SearchSource: String {
  case OpenStreetMap = "osm"
  case OpenAddresses = "oa"
  case Quattroshapes = "qs"
  case GeoNames = "gn"
  /// Creates a comma separated string for a list of sources.
  public static func dataSourceString(_ sourceList: [SearchSource]) -> String {
    return sourceList.map{$0.rawValue}.joined(separator: ",")
  }
}

/// Represents a layer to return results for.
public enum LayerFilter: String {
  case venue, address, country, region, county, locality, localadmin, neighbourhood, coarse
  /// Creates a comma separated string for a list of layers.
  public static func layerString(_ layers: [LayerFilter]) -> String {
    return layers.map{$0.rawValue}.joined(separator: ",")
  }
}

/// Generic protocol from which all others extend.
public protocol APIConfigData {
  /// The Pelias endpoing for this configuration.
  var urlEndpoint: URL { get }
  /// The query items used to construct the request. In most cases you will not have to interact directly with this value because items will be appended via properties. However, when setting an API key or other items not available via properties, you can use this value directly.
  var queryItems: [String:URLQueryItem] { get set }
  /// Closure to execute when the request finishes or fails.
  var completionHandler: (PeliasResponse) -> Void { get set }
  /// Returns the fully qualified search url.
  func searchUrl() -> URL
  /// Appends entries to queryItems given the properties set in implementing classes.
  mutating func appendQueryItem(_ name: String, value: String?)
}

/// Extensions for APIConfigData which handles appending queryitems and constructing a search url.
public extension APIConfigData {
  /// Appends entries to queryItems given the properties set in implementing classes.
  mutating public func appendQueryItem(_ name: String, value: String?) {
    if let queryValue = value, queryValue.isEmpty == false{
      let queryItem = URLQueryItem(name: name, value: queryValue)
      queryItems[name] = queryItem;
      
    }
  }
  /// Returns the fully qualified search url.
  public func searchUrl() -> URL {
    var urlComponents = URLComponents(url: urlEndpoint, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = Array(queryItems.values)
    return urlComponents!.url!
  }
}
/// Protocol which adds search text to 'APIConfigData'.
public protocol GenericSearchAPIConfigData : APIConfigData {
  /// Text to search for within components of the location.
  var searchText: String { get set }
}
/// Protocol which adds a focus point to 'GenericSearchAPIConfigData'.
public protocol AutocompleteAPIConfigData: GenericSearchAPIConfigData {
  /// The point to order results by where results closer to this value are returned higher in the list.
  var focusPoint: GeoPoint { get set }
}
/// Protocol for search requests.
public protocol SearchAPIConfigData : GenericSearchAPIConfigData {
/// The point to order results by where results closer to this value are returned higher in the list.
  var focusPoint: GeoPoint? { get set }
  /// The number of results to return.
  var numberOfResults: Int? { get set }
  /// The boundary country (in ISO-3166 alpha-2 or alpha-3 format) to limit results by.
  var boundaryCountry: String? { get set }
  /// The rectangular boundary to limit results to.
  var boundaryRect: SearchBoundaryRect? { get set }
  /// The circular boundary to limit results to.
  var boundaryCircle: SearchBoundaryCircle? { get set }
  /// Sources to fetch data from.
  var dataSources: [SearchSource]? { get set }
  /// Layers to fetch sources from.
  var layers: [LayerFilter]? { get set }
}
/// Protocol for reverse geocoding requests.
public protocol ReverseAPIConfigData: APIConfigData {
  /// The point to reverse geocode.
  var point: GeoPoint { get set }
  /// The number of results to return.
  var numberOfResults: Int? { get set }
  /// Sources to fetch data from.
  var dataSources: [SearchSource]? { get set }
  /// The boundary country (in ISO-3166 alpha-2 or alpha-3 format) to limit results by.
  var boundaryCountry: String? { get set }
  /// Layers to fetch sources from.
  var layers: [LayerFilter]? { get set }
}
/// Protocol for place requests.
public protocol PlaceAPIConfigData: APIConfigData {
  /// The place gids to fetch info for.
  var gids: [String] { get set }
}
/// Protocol for api responses.
public protocol APIResponse {
  /// Raw data.
  var data: Data? { get }
  /// The response object if the request completed.
  var response: URLResponse? { get }
  /// The error if one occured.
  var error: NSError? { get }
}
