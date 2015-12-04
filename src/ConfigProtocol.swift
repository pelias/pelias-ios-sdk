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

enum SearchSource {
  case OpenStreetMap
  case OpenAddresses
  case Quattroshapes
  case GeoNames
}

enum LayerFilter{
  case Venue, Address, Country, Region, County, Locality, Localadmin, Neighborhood
}

protocol APIConfigData {
  var urlEndpoint: NSURL { get }
  var apiKey: String? { get }
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