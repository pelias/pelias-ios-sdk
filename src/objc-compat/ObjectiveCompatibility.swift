//
//  ObjectiveCompatibility.swift
//  pelias-ios-sdk
//
//  Created by Matt on 1/18/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

class SearchRectWrapper: NSObject {
  let rect: SearchBoundaryRect
  init(minLatLong: GeoPointWrapper, maxLatLong: GeoPointWrapper) {
    rect = SearchBoundaryRect(minLatLong: minLatLong.point, maxLatLong: maxLatLong.point)
  }
  
  init(boundaryRect: SearchBoundaryRect) {
    rect = boundaryRect
  }
}

class SearchCircleWrapper: NSObject {
  let circle:  SearchBoundaryCircle
  init(center: GeoPointWrapper, radius: Double) {
    circle = SearchBoundaryCircle(center: center.point, radius: radius)
  }
  
  init(boundaryCircle: SearchBoundaryCircle){
    circle = boundaryCircle
  }
}

class GeoPointWrapper: NSObject {
  let point: GeoPoint
  init(latitude: Double, longitude: Double) {
    point = GeoPoint(latitude: latitude, longitude: longitude)
  }
  
  init(geoPoint: GeoPoint) {
    point = geoPoint
  }
}

enum SearchSourceWrapper: Int {
  case OpenStreetMap = 1, OpenAddresses, Quattroshapes, GeoNames
}

func unwrapSearchSourceWrapper(sources: [SearchSourceWrapper]) -> [SearchSource] {
  var newSources: [SearchSource] = []
  for wrapper in sources {
    switch wrapper {
    case .OpenStreetMap:
      newSources.append(SearchSource.OpenStreetMap)
    case .OpenAddresses:
      newSources.append(SearchSource.OpenAddresses)
    case .Quattroshapes:
      newSources.append(SearchSource.Quattroshapes)
    case.GeoNames:
      newSources.append(SearchSource.GeoNames)
    }
  }
  return newSources
}

func wrapSearchSources(sources: [SearchSource]) -> [SearchSourceWrapper] {
  var newSources: [SearchSourceWrapper] = []
  for wrapper in sources {
    switch wrapper {
    case .OpenStreetMap:
      newSources.append(SearchSourceWrapper.OpenStreetMap)
    case .OpenAddresses:
      newSources.append(SearchSourceWrapper.OpenAddresses)
    case .Quattroshapes:
      newSources.append(SearchSourceWrapper.Quattroshapes)
    case.GeoNames:
      newSources.append(SearchSourceWrapper.GeoNames)
    }
  }
  return newSources
}

func searchSourceDataString(sourceList: [SearchSourceWrapper]) -> String? {
  return SearchSource.dataSourceString(unwrapSearchSourceWrapper(sourceList))
}

enum LayerFilterWrapper: Int {
  case venue = 1, address, country, region, county, locality, localadmin, neighbourhood, coarse
}

func unwrapLayerFilterWrapper(layers: [LayerFilterWrapper]) -> [LayerFilter] {
  var newLayers: [LayerFilter] = []
  for wrapper in layers {
    switch wrapper {
    case .address:
      newLayers.append(LayerFilter.address)
    case .coarse:
      newLayers.append(LayerFilter.coarse)
    case .country:
      newLayers.append(LayerFilter.country)
    case .county:
      newLayers.append(LayerFilter.county)
    case .localadmin:
      newLayers.append(LayerFilter.localadmin)
    case .locality:
      newLayers.append(LayerFilter.locality)
    case .neighbourhood:
      newLayers.append(LayerFilter.neighbourhood)
    case .region:
      newLayers.append(LayerFilter.region)
    case .venue:
      newLayers.append(LayerFilter.venue)
    }
  }
  return newLayers
}

func wrapLayerFilter(layers: [LayerFilter]) -> [LayerFilterWrapper] {
  var newLayers: [LayerFilterWrapper] = []
  for wrapper in layers {
    switch wrapper {
    case .address:
      newLayers.append(LayerFilterWrapper.address)
    case .coarse:
      newLayers.append(LayerFilterWrapper.coarse)
    case .country:
      newLayers.append(LayerFilterWrapper.country)
    case .county:
      newLayers.append(LayerFilterWrapper.county)
    case .localadmin:
      newLayers.append(LayerFilterWrapper.localadmin)
    case .locality:
      newLayers.append(LayerFilterWrapper.locality)
    case .neighbourhood:
      newLayers.append(LayerFilterWrapper.neighbourhood)
    case .region:
      newLayers.append(LayerFilterWrapper.region)
    case .venue:
      newLayers.append(LayerFilterWrapper.venue)
    }
  }
  return newLayers
}

func layerFilterString(layers: [LayerFilterWrapper]) -> String? {
  return LayerFilter.layerString(unwrapLayerFilterWrapper(layers))
}

public class PeliasSearchConfigWrapper: NSObject {
  var configObject: PeliasSearchConfig
  
  var urlEndpoint: NSURL {
    get {
      return self.configObject.urlEndpoint
    }
    set(url) {
      self.configObject.urlEndpoint = url
    }
  }
  
  var searchText: String {
    get {
      return configObject.searchText;
    }
    set(text) {
      configObject.searchText = text
    }
  }
  
  //Optional Query Params
  var queryItems: [String:NSURLQueryItem] {
    get {
      return configObject.queryItems
    }
    set(array) {
      configObject.queryItems = array
    }
  }
  
  var apiKey: String? {
    get {
      return configObject.apiKey
    }
    set(text) {
      configObject.apiKey = text
    }
  }
  
  var numberOfResults: Int? {
    get {
      return configObject.numberOfResults
    }
    set(num) {
      configObject.numberOfResults = num
    }
  }
  
  var boundaryCountry: String? {
    get {
      return configObject.boundaryCountry
    }
    set(text) {
      configObject.boundaryCountry = text
    }
  }
  
  var boundaryRect: SearchRectWrapper? {
    get {
      if let rect = configObject.boundaryRect{
        return SearchRectWrapper(boundaryRect: rect)
      }
      return nil
    }
    set (rectWrapper) {
      configObject.boundaryRect = rectWrapper?.rect
    }
  }
  
  var boundaryCircle: SearchCircleWrapper? {
    get {
      if let circle = configObject.boundaryCircle {
        return SearchCircleWrapper(boundaryCircle: circle)
      }
      return nil
    }
    set(circleWrapper) {
      configObject.boundaryCircle = circleWrapper?.circle
    }
  }
  
  var focusPoint: GeoPointWrapper? {
    get {
      if let point = configObject.focusPoint {
        return GeoPointWrapper(geoPoint: point)
      }
      return nil
    }
    set(pointWrapper) {
      configObject.focusPoint = pointWrapper?.point
    }
  }
  
  var dataSources: [SearchSourceWrapper]? {
    get {
      if let sources = configObject.dataSources {
        return wrapSearchSources(sources)
      }
      return nil
    }
    set {
      if let sources = dataSources {
        configObject.dataSources = unwrapSearchSourceWrapper(sources)
      }
    }
  }
  
  var layers: [LayerFilterWrapper]? {
    get {
      if let layerArray = configObject.layers {
        return wrapLayerFilter(layerArray)
      }
      return nil
    }
    set {
      if let layerArray = layers {
        configObject.layers = unwrapLayerFilterWrapper(layerArray)
      }
    }
  }
  
  init(searchText: String, completionHandler: (PeliasSearchResponse) -> Void){
    self.configObject = PeliasSearchConfig(searchText: searchText, completionHandler: completionHandler)
  }
}