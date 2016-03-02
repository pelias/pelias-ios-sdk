//
//  PeliasSearchManagerTests.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/5/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import XCTest
@testable import pelias_ios_sdk

class PeliasSearchManagerTests: XCTestCase {
  var testOperationQueue = NSOperationQueue()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testOperationQueue.suspended = true
    PeliasSearchManager.sharedInstance.autocompleteTimeDelay = 0.0
  }
  
  func testCancellation() {
    let searchConfig = PeliasSearchConfig(searchText: "Test", completionHandler: { (searchResponse) -> Void in
      XCTFail("The callback was executed - that means cancellation failed")
    })
    let op = PeliasOperation(config: searchConfig)
    testOperationQueue.addOperation(op)
    op.cancel()
    testOperationQueue.suspended = false
    XCTAssert(op.cancelled == true)
  }
  
  func testRateLimits() {
    PeliasSearchManager.sharedInstance.autocompleteTimeDelay = 5.0 //Enables queuing
    let expectation = expectationWithDescription("Test Rate Limiter")
    let config1 = PeliasAutocompleteConfig(searchText: "Test", focusPoint: GeoPoint(latitude: 40.7312973034393, longitude: -73.99896644276561)) { (response) -> Void in
      XCTAssertNotNil(response)
      expectation.fulfill()
    }
    let config2 = PeliasAutocompleteConfig(searchText: "Testing", focusPoint: GeoPoint(latitude: 40.7312973034393, longitude: -73.99896644276561)) { (response) -> Void in
      XCTFail("Callback executed - not rate limited correctly")
    }
    
    PeliasSearchManager.sharedInstance.autocompleteQuery(config1)
    let opToCancel = PeliasSearchManager.sharedInstance.autocompleteQuery(config2)
    waitForExpectationsWithTimeout(3.0) { (error) -> Void in
      //Using expectations allows the runloop to tick, the timer code to get enacted and objects to land in the correct places in the code
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
      XCTAssert(opToCancel.cancelled == false)
      XCTAssert(opToCancel == PeliasSearchManager.sharedInstance.queuedAutocompleteOp!)
      opToCancel.cancel()
    }
  }
    
  func testResponseObjectEncoding() {
    let seed:[String:AnyObject] = ["SuperSweetKey":"SuperSweetValue"]
    
    let testResponse = PeliasSearchResponse(parsedResponse: seed)
    
    PeliasSearchResponse.encode(testResponse)
    
    let decodedObject = PeliasSearchResponse.decode()
    XCTAssert(testResponse.parsedResponse == decodedObject?.parsedResponse)
  }
  
  func testErrorHandling() {
    //Little known fact: Getting the tests bundle that contains the fixtures is not done the normal NSBundle.mainBundle() route, because that will still yield the application bundle
    let testBundle = NSBundle.init(forClass: PeliasSearchManagerTests.self)
    let jsonData: NSData? = NSData(contentsOfFile: testBundle.pathForResource("error_response", ofType: "json")!)
    let testResponse = PeliasResponse(data: jsonData, response: nil, error: nil)
    XCTAssertNotNil(testResponse.parsedError)
    XCTAssertNil(testResponse.parsedResponse)
  }
  
}
