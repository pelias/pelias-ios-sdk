//
//  PeliasAutocompleteConfig.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/28/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

/// Structure used to encapsulate request parameters for autocomplete requests.
public struct PeliasAutocompleteConfig : AutocompleteAPIConfigData {
  /// Place endpoint on Pelias.
  public var urlEndpoint = URL.init(string: Constants.URL.autocomplete, relativeTo: PeliasSearchManager.sharedInstance.baseUrl as URL)!
  /// All the query items that will be used to make the request.
  public var queryItems = [String:URLQueryItem]()
  /// Completion handler invoked on success or failure.
  public var completionHandler: (PeliasResponse) -> Void
  /// Text to search for within components of the location. This value is required to execute an autocomplete request and will get converted into the appropriate query item.
  public var searchText: String{
    didSet {
      appendQueryItem(Constants.API.text, value: searchText)
    }
  }
  /// The point to order results by where results closer to this value are returned higher in the list. This value is optional and will get converted into the appropriate query items. Default is none.
  public var focusPoint: GeoPoint {
    didSet {
      appendQueryItem(Constants.API.focusPointLat, value: String(focusPoint.latitude))
      appendQueryItem(Constants.API.focusPointLon, value: String(focusPoint.longitude))
    }
  }
  /**
   Initialize an autocomplete config with all the required parameters and a focus point. These values will get converted into the appropriate query items.

   - parameter searchText: Text to search for within components of the location.
   - parameter focusPoint:  The point to order results around where results closer to this value are returned higher in the list.
   - parameter completionHandler: The closure to execute when the request suceeds or fails.
   */
  public init(searchText: String, focusPoint: GeoPoint, completionHandler: @escaping (PeliasResponse) -> Void) {
    self.searchText = searchText
    self.completionHandler = completionHandler
    self.focusPoint = focusPoint
    defer {
      //didSet will not fire because self is not setup so we have to do this manually
      appendQueryItem(Constants.API.text, value: searchText)
      appendQueryItem(Constants.API.focusPointLat, value: String(focusPoint.latitude))
      appendQueryItem(Constants.API.focusPointLon, value: String(focusPoint.longitude))
    }
  }
}
