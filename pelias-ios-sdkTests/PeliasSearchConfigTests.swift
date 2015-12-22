//
//  PeliasSearchConfigTests.swift
//  pelias-ios-sdk
//
//  Created by Matt on 12/4/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import XCTest
@testable import pelias_ios_sdk

class PeliasSearchConfigTests: XCTestCase {
  
  var config = PeliasSearchConfig(searchText: "test", completionHandler: { (searchResponse) -> Void in })
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    config = PeliasSearchConfig(searchText: "test", completionHandler: { (searchResponse) -> Void in })
  }
  
  override class func setUp(){
    SearchManager.sharedInstance.apiKey = "1234"
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testInit(){
    XCTAssert(config.searchText == "test", "Initialization failed. Search Text is not what we expect")
    XCTAssert(config.apiKey == "1234", "Initialization failed. API Key is not what we expect")
  }
  
  func testTextQueryItem(){
    XCTAssert(config.queryItems["text"]?.value == "test", "Text is not the expected string")
  }
  
  func testApiKeyQueryItem(){
    XCTAssert(config.queryItems["api_key"]?.value == "1234", "apiKey not set correctly")
  }
  
  func testNumberOfResults(){
    config.numberOfResults = 5;
    XCTAssert(config.queryItems["size"]?.value == "5", "numberOfResults not set correctly")
  }
  
  func testBoundaryCountry(){
    config.boundaryCountry = "USA"
    XCTAssert(config.queryItems["boundary.country"]?.value == "USA", "boundaryCountry not set correctly")
  }
  
  func testBoundaryRect(){
    var boundaryRect: SearchBoundaryRect?
    boundaryRect = SearchBoundaryRect(
      minLatLong: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      maxLatLong: GeoPoint(latitude: 40.706866, longitude: -74.011319))
    config.boundaryRect = boundaryRect
    XCTAssert(config.queryItems["boundary.rect.min_lat"]?.value == "40.713008")
    XCTAssert(config.queryItems["boundary.rect.min_lon"]?.value == "-74.013169")
    XCTAssert(config.queryItems["boundary.rect.max_lat"]?.value == "40.706866")
    XCTAssert(config.queryItems["boundary.rect.max_lon"]?.value == "-74.011319")
  }
  
  func testBoundardCircle(){
    var boundaryCircle: SearchBoundaryCircle?
    boundaryCircle = SearchBoundaryCircle(
      center: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      radius: 300)
    config.boundaryCircle = boundaryCircle
    XCTAssert(config.queryItems["boundary.cirle.lat"]?.value == "40.713008")
    XCTAssert(config.queryItems["boundary.circle.lon"]?.value == "-74.013169")
    XCTAssert(config.queryItems["boundary.circle.radius"]?.value == "300.0")
  }
  
  func testFocusPoint() {
    var focusPoint: GeoPoint?
    focusPoint = GeoPoint(latitude: 40.713008, longitude: -74.013169)
    config.focusPoint = focusPoint
    XCTAssert(config.queryItems["focus.point.lat"]?.value == "40.713008")
    XCTAssert(config.queryItems["focus.point.lon"]?.value == "-74.013169")
  }
}
