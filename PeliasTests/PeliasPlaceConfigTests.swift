//
//  PeliasPlaceConfigTests.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/17/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import XCTest
@testable import Pelias

class PeliasPlaceConfigTests: XCTestCase {
  
  func testInit() {
    let placeId = "1234"
    let place = PeliasPlaceConfig(gids: [placeId]) { (response) -> Void in
      print("Neat")
    }
    XCTAssertNotNil(place.searchUrl())
  }

  func testQueryItemsBuild() {
    let placeIds = ["gn:address:1234"]
    let place = PeliasPlaceConfig(gids: placeIds) { (response) -> Void in
      print("Neat")
    }

    let queryItem = place.queryItems[Constants.API.ids]
    let queryString = queryItem?.value
    XCTAssert(queryString == "gn:address:1234", "String is not equal - \(String(describing: queryString))")
  }

  func testQueryItemsBuildMultipleIds() {
    let placeIds = ["gn:address:1234", "test:key:gid"]
    let place = PeliasPlaceConfig(gids: placeIds) { (response) -> Void in
      print("Neat")
    }
    
    let queryItem = place.queryItems[Constants.API.ids]
    let queryString = queryItem?.value
    XCTAssert(queryString == "gn:address:1234,test:key:gid", "String is not equal - \(String(describing: queryString))")
  }
}
