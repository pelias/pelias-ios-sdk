//
//  PeliasPlaceConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/16/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to encapsulate request parameters for place requests.
public struct PeliasPlaceConfig : PlaceAPIConfigData {
  /// Place endpoint on Pelias.
  public var urlEndpoint = URL.init(string: Constants.URL.place, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  /// All the query items that will be used to make the request.
  public var queryItems = [String:URLQueryItem]()
  /// Completion handler invoked on success or failure.
  public var completionHandler: (PeliasResponse) -> Void
  /// The places to fetch info for. These values will get converted into the appropriate query items.
  public var places: [PlaceAPIQueryItem] {
    didSet {
      buildPlaceQueryItem()
    }
  }
  /**
   Initialize a place config with all the required parameters. These values will get converted into the appropriate query items.

   - parameter places: The places to request info for.
   - parameter completionHandler: The closure to execute when the request suceeds or fails.
   */
  public init(places: [PlaceAPIQueryItem], completionHandler: @escaping (PeliasResponse) -> Void) {
    self.places = places
    self.completionHandler = completionHandler

    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      buildPlaceQueryItem()
    }
  }
  
  mutating func buildPlaceQueryItem() {
    if places.count <= 0 {
      return
    }
    var queryString = ""
    for place in places {
      let addition = "\(place.dataSource.rawValue):\(place.layer.rawValue):\(place.placeId)"
      if queryString.isEmpty {
        queryString = addition
      } else {
        queryString += "&\(addition)"
      }
    }
    
    appendQueryItem(Constants.API.ids, value: queryString)
  }
}

/// Encapsulates info needed to create a fully qualified place id.
public struct PeliasPlaceQueryItem : PlaceAPIQueryItem {
  /// Place id.
  public var placeId: String
  /// Place data source.
  public var dataSource: SearchSource
  /// Place layer.
  public var layer: LayerFilter

  /**
   Creates a new query item configured with all properties needed to construct a place id.
   
   - parameter placeId: The place id.
   - parameter dataSource: The place data source.
   - parameter layer: The place layer.
   */
  public init(placeId: String, dataSource: SearchSource, layer: LayerFilter) {
    self.placeId = placeId
    self.dataSource = dataSource
    self.layer = layer
  }
}
