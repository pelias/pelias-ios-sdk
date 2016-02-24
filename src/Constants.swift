//
//  Constants.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/23/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation

struct Constants {
  struct API {
    static let focusPointLat = "focus.\(pointLat)"
    static let focusPointLon = "focus.\(pointLon)"
    static let text = "text"
    static let key = "api_key"
    static let pointLat = "point.lat"
    static let pointLon = "point.lon"
    static let size = "size"
    static let sources = "sources"
    static let layers = "layers"
    static let ids = "ids"
  }
  
  struct Boundary {
    static let boundary = "boundary"
    static let country = "\(boundary).country"
    struct Rect {
      static let rect = "\(boundary).rect"
      static let minLat = "\(rect).min_lat"
      static let minLon = "\(rect).min_lon"
      static let maxLat = "\(rect).max_lat"
      static let maxLon = "\(rect).max_lon"
    }
    struct Circle {
      static let circle = "\(boundary).circle"
      static let lat = "\(circle).lat"
      static let lon = "\(circle).lon"
      static let radius = "\(circle).radius"
    }
  }
  
  struct URL {
    static let base = "https://search.mapzen.com"
    static let baseVersion = "v1/"
    static let autocomplete = "\(baseVersion)autocomplete"
    static let reverse = "\(baseVersion)reverse"
    static let search = "\(baseVersion)search"
    static let place = "\(baseVersion)place"
  }
}
