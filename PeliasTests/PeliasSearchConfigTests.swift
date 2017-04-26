//
//  PeliasSearchConfigTests.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/4/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import XCTest
@testable import Pelias

class PeliasSearchConfigTests: XCTestCase {
  
  var config = PeliasSearchConfig(searchText: "test", completionHandler: { (searchResponse) -> Void in })
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    config = PeliasSearchConfig(searchText: "test", completionHandler: { (searchResponse) -> Void in })
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testInit() {
    XCTAssert(config.searchText == "test", "Initialization failed. Search Text is not what we expect")
  }
  
  func testTextQueryItem( ){
    XCTAssert(config.queryItems[Constants.API.text]?.value == "test", "Text is not the expected string")
  }
  
  func testNumberOfResults() {
    config.numberOfResults = 5;
    XCTAssert(config.queryItems[Constants.API.size]?.value == "5", "numberOfResults not set correctly")
  }
  
  func testBoundaryCountry() {
    config.boundaryCountry = "USA"
    XCTAssert(config.queryItems[Constants.Boundary.country]?.value == "USA", "boundaryCountry not set correctly")
  }
  
  func testBoundaryRect() {
    var boundaryRect: SearchBoundaryRect?
    boundaryRect = SearchBoundaryRect(
      minLatLong: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      maxLatLong: GeoPoint(latitude: 40.706866, longitude: -74.011319))
    config.boundaryRect = boundaryRect
    XCTAssert(config.queryItems[Constants.Boundary.Rect.minLat]?.value == "40.713008", "boundary.rect.min_lat not set correctly")
    XCTAssert(config.queryItems[Constants.Boundary.Rect.minLon]?.value == "-74.013169", "boundary.rect.min_lon not set correctly")
    XCTAssert(config.queryItems[Constants.Boundary.Rect.maxLat]?.value == "40.706866", "boundary.rect.max_lat not set correctly")
    XCTAssert(config.queryItems[Constants.Boundary.Rect.maxLon]?.value == "-74.011319", "boundary.rect.max_lon not set correctly")
  }
  
  func testBoundardCircle() {
    var boundaryCircle: SearchBoundaryCircle?
    boundaryCircle = SearchBoundaryCircle(
      center: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      radius: 300)
    config.boundaryCircle = boundaryCircle
    XCTAssert(config.queryItems[Constants.Boundary.Circle.lat]?.value == "40.713008", "boundary.cirle.lat not set correctly")
    XCTAssert(config.queryItems[Constants.Boundary.Circle.lon]?.value == "-74.013169", "boundary.cirle.lon not set correctly")
    XCTAssert(config.queryItems[Constants.Boundary.Circle.radius]?.value == "300.0", "boundary.circle.radius not set correctly")
  }
  
  func testFocusPoint() {
    var focusPoint: GeoPoint?
    focusPoint = GeoPoint(latitude: 40.713008, longitude: -74.013169)
    config.focusPoint = focusPoint
    XCTAssert(config.queryItems[Constants.API.focusPointLat]?.value == "40.713008", "boundary.cirle.lat not set correctly")
    XCTAssert(config.queryItems[Constants.API.focusPointLon]?.value == "-74.013169", "boundary.cirle.lon not set correctly")
  }

  func testBasicSearchURL() {
    let validURL = "https://search.mapzen.com/v1/search?text=test"
    let testUrl = config.searchUrl()
    XCTAssert(testUrl.absoluteString == validURL)
  }
}
