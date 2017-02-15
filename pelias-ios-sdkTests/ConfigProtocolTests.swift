//
//  ConfigProtocolTests.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/11/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import XCTest
@testable import pelias_ios_sdk

class ConfigProtocolTests: XCTestCase {
  
  func testBoundaryRectEquatableImplementation() {
    let boundaryRect1 = SearchBoundaryRect(
      minLatLong: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      maxLatLong: GeoPoint(latitude: 40.706866, longitude: -74.011319))
    
    let boundaryRect2 = SearchBoundaryRect(
      minLatLong: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      maxLatLong: GeoPoint(latitude: 40.706866, longitude: -74.011319))
    
    XCTAssert(boundaryRect1 == boundaryRect2)
  }
  
  func testGeoPointEquatableImplementation() {
    let geoPoint1 = GeoPoint(latitude: 1, longitude: 2)
    let geoPoint2 = GeoPoint(latitude: 1, longitude: 2)
    
    XCTAssert(geoPoint1 == geoPoint2)
  }
  
  func testSearchBoundaryCircleEquatableImplementation() {
    let searchBoundaryCircle1 = SearchBoundaryCircle(center: GeoPoint(latitude: 40.713008, longitude: -74.013169), radius: 123)
    let searchBoundaryCircle2 = SearchBoundaryCircle(center: GeoPoint(latitude: 40.713008, longitude: -74.013169), radius: 123)
    
    XCTAssert(searchBoundaryCircle1 == searchBoundaryCircle2)
  }
}
