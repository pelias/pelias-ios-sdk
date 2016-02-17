//
//  PeliasPlaceConfigTests.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/17/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import XCTest
@testable import pelias_ios_sdk

class PeliasPlaceConfigTests: XCTestCase {
  
  func testInit() {
    let item = PeliasPlaceQueryItem(placeId: "1234", dataSource: SearchSource.GeoNames, layer: LayerFilter.address)
    let place = PeliasPlaceConfig(places: [item]) { (response) -> Void in
      print("Neat")
    }
    XCTAssertNotNil(place.searchUrl())
  }
  
  func testQueryItemsBuild() {
    let item = PeliasPlaceQueryItem(placeId: "1234", dataSource: SearchSource.GeoNames, layer: LayerFilter.address)
    let place = PeliasPlaceConfig(places: [item]) { (response) -> Void in
      print("Neat")
    }
    
    let queryItem = place.queryItems["ids"]
    let queryString = queryItem?.value
    XCTAssert(queryString == "gn:address:1234", "String is not equal - \(queryString)")
  }
  
}
