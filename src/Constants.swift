//
//  Constants.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/23/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

public struct Constants {
  public struct API {
    public static let focusPointLat = "focus.\(pointLat)"
    public static let focusPointLon = "focus.\(pointLon)"
    public static let text = "text"
    public static let key = "api_key"
    public static let pointLat = "point.lat"
    public static let pointLon = "point.lon"
    public static let size = "size"
    public static let sources = "sources"
    public static let layers = "layers"
    public static let ids = "ids"
  }
  
  public struct Boundary {
    public static let boundary = "boundary"
    public static let country = "\(boundary).country"
    public struct Rect {
      public static let rect = "\(boundary).rect"
      public static let minLat = "\(rect).min_lat"
      public static let minLon = "\(rect).min_lon"
      public static let maxLat = "\(rect).max_lat"
      public static let maxLon = "\(rect).max_lon"
    }
    public struct Circle {
      public static let circle = "\(boundary).circle"
      public static let lat = "\(circle).lat"
      public static let lon = "\(circle).lon"
      public static let radius = "\(circle).radius"
    }
  }
  
  public struct URL {
    public static let base = "https://search.mapzen.com"
    public static let baseVersion = "v1/"
    public static let autocomplete = "\(baseVersion)autocomplete"
    public static let reverse = "\(baseVersion)reverse"
    public static let search = "\(baseVersion)search"
    public static let place = "\(baseVersion)place"
  }
}
