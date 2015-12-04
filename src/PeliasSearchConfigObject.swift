//
//  PeliasSearchConfigObject.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasSearchConfig : SearchAPIConfigData {

  var searchText: String
  
  var urlEndpoint = NSURL.init(string: "/v1/search", relativeToURL: SearchManager.sharedInstance.baseUrl)!
  var apiKey: String?

  var numberOfResults: Int?
  var boundaryCountry: String?
  var boundaryRect: SearchBoundaryRect?
  var boundaryCircle: SearchBoundaryCircle?
  var focusPoint: GeoPoint?
  var dataSources: [SearchSource]?
  var layers: [LayerFilter]?
  var completionHandler: (PeliasSearchResponse) -> Void
  
  init(searchText: String, completionHandler: (PeliasSearchResponse) -> Void){
    self.searchText = searchText
    self.completionHandler = completionHandler
    print(urlEndpoint)
    apiKey = SearchManager.sharedInstance.apiKey
    let searchTextQueryItem = NSURLQueryItem.init(name: "text", value: searchText)
    var queryItems = [searchTextQueryItem]
    if let key = apiKey{
      let queryItem = NSURLQueryItem.init(name: "api_key", value: key)
      queryItems.append(queryItem);
      
    }
    let urlComponents = NSURLComponents.init(URL: urlEndpoint, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = queryItems
    urlEndpoint = urlComponents!.URL!

    print(urlEndpoint)
  }
}