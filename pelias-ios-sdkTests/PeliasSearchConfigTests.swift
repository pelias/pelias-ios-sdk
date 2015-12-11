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
    XCTAssertEqual(config.searchText, "test", "Initialization failed. Search Text is not what we expect")
  }
  
  func testApiKey(){
    XCTAssert(config.apiKey == "1234", "apiKey not getting set correctly")
  }
  
  func testBoundaryRect(){
    var boundaryRect: SearchBoundaryRect?
    boundaryRect = SearchBoundaryRect(
      minLatLong: GeoPoint(latitude: 40.713008, longitude: -74.013169),
      maxLatLong: GeoPoint(latitude: 40.706866, longitude: -74.011319))
    config.boundaryRect = boundaryRect
    XCTAssertEqual(config.boundaryRect, boundaryRect, "Boundary Rect Not Set Correctly")
  }
}
