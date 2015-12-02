//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasSearchConfig : SearchAPIConfigData {
  let urlEndpoint: NSURL
  let apiKey: String
  
  var searchText: String
  var numberOfResults: Int?
  var boundaryCountry: String?
  var boundaryRect: SearchBoundaryRect?
  var boundaryCircle: SearchBoundaryCircle?
  var focusPoint: GeoPoint?
  var dataSources: [SearchSource]?
  var layers: [LayerFilter]?
}