//
//  Constants.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/23/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

/// Constants used by 'PeliasSearchManager' and its related config classes.
public struct Constants {

  /// Constants for top level parameters used by the configs to construct API requests against Pelias.
  public struct API {
    /** 
     Used by the autocomplete and search configs to prioritize results close to a geographic point. Results closest to the given lat and lon
     focus points will appear higher in the results.
    */
    public static let focusPointLat = "focus.\(pointLat)"
    /**
     Used by the autocomplete and search configs to prioritize results close to a geographic point. Results closest to the given lat and lon
     focus points will appear higher in the results.
     */
    public static let focusPointLon = "focus.\(pointLon)"
    /// Used by the autocomplete and search configs to limit results to components of a location.
    public static let text = "text"
    /// The Mapzen API Key
    public static let key = "api_key"
    /// Used by the reverse config to indicate latitude of place that should be looked up.
    public static let pointLat = "point.lat"
    /// Used by the reverse config to indicate longitude of place that should be looked up.
    public static let pointLon = "point.lon"
    /// Used by the reverse config to limit the number of results returned.
    public static let size = "size"
    /// Used by the search and reverse configs to indicate which sources within Pelias results should be returned from.
    public static let sources = "sources"
    /// Used by the search and reverse configs to indicate which layers to restrict results to.
    public static let layers = "layers"
    /// Used by the place config to indicate pelias place ids to fetch details for.
    public static let ids = "ids"
  }

  /// Constants for boundary parameters used by the configs to construct API requests against Pelias.
  public struct Boundary {
    /// Not used directly but instead as part of the derived constants below.
    private static let boundary = "boundary"
    /// Used by the reverse and search configs to limit results to a specific country.
    public static let country = "\(boundary).country"
    /// Constants for a boundary's rect parameters used by the configs to construct API requests against Pelias.
    public struct Rect {
      /// Not used directly but instead as part of the derived constants below.
      private static let rect = "\(boundary).rect"
      /// Used by the search config to limit results to a rectangular region.
      public static let minLat = "\(rect).min_lat"
      /// Used by the search config to limit results to a rectangular region.
      public static let minLon = "\(rect).min_lon"
      /// Used by the search config to limit results to a rectangular region.
      public static let maxLat = "\(rect).max_lat"
      /// Used by the search config to limit results to a rectangular region.
      public static let maxLon = "\(rect).max_lon"
    }
    /// Constants for a boundary's circle parameters used by the configs to construct API requests against Pelias.
    public struct Circle {
      /// Not used directly but instead as part of the derived constants below.
      private static let circle = "\(boundary).circle"
      /// Used by the search config to limit results to a circular region.
      public static let lat = "\(circle).lat"
      /// Used by the search config to limit results to a circular region.
      public static let lon = "\(circle).lon"
      /// Used by the search config to limit results to a circular region. Units are in kilometers.
      public static let radius = "\(circle).radius"
    }
  }
  /// Constants for the base url and available endpoints to make requests against Pelias.
  public struct URL {
    /// Default base url for Pelias requests.
    public static let base = "https://search.mapzen.com"
    /// Pelias version.
    public static let baseVersion = "v1/"
    /// Autocomplete endpoint.
    public static let autocomplete = "\(baseVersion)autocomplete"
    /// Reverse geo endpoing.
    public static let reverse = "\(baseVersion)reverse"
    /// Search endpoint.
    public static let search = "\(baseVersion)search"
    /// Place endpoint.
    public static let place = "\(baseVersion)place"
  }
}
