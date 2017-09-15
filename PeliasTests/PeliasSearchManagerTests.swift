//
//  PeliasSearchManagerTests.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/5/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import XCTest
@testable import Pelias

class PeliasSearchManagerTests: XCTestCase {
  var testOperationQueue = OperationQueue()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    testOperationQueue.isSuspended = true
    PeliasSearchManager.sharedInstance.operationQueue.isSuspended = true
    PeliasSearchManager.sharedInstance.autocompleteTimeDelay = 0.0
  }
  
  func testCancellation() {
    let searchConfig = PeliasSearchConfig(searchText: "Test", completionHandler: { (searchResponse) -> Void in
      XCTFail("The callback was executed - that means cancellation failed")
    })
    let op = PeliasOperation(config: searchConfig)
    testOperationQueue.addOperation(op)
    op.cancel()
    testOperationQueue.isSuspended = false
    XCTAssert(op.isCancelled == true)
  }

//Commented out - Mapzen's hosted pelias doesn't always respond in time which causes failing tests. Will need to rethink how to effectively test this
//  func testRateLimits() {
//    PeliasSearchManager.sharedInstance.autocompleteTimeDelay = 5.0 //Enables queuing
//    let expectation = expectationWithDescription("Test Rate Limiter")
//    let config1 = PeliasAutocompleteConfig(searchText: "Test", focusPoint: GeoPoint(latitude: 40.7312973034393, longitude: -73.99896644276561)) { (response) -> Void in
//      XCTAssertNotNil(response)
//      expectation.fulfill()
//    }
//    let config2 = PeliasAutocompleteConfig(searchText: "Testing", focusPoint: GeoPoint(latitude: 40.7312973034393, longitude: -73.99896644276561)) { (response) -> Void in
//      XCTFail("Callback executed - not rate limited correctly")
//    }
//    
//    PeliasSearchManager.sharedInstance.autocompleteQuery(config1)
//    let opToCancel = PeliasSearchManager.sharedInstance.autocompleteQuery(config2)
//    waitForExpectationsWithTimeout(3.0) { (error) -> Void in
//      //Using expectations allows the runloop to tick, the timer code to get enacted and objects to land in the correct places in the code
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//      XCTAssert(opToCancel.cancelled == false)
//      XCTAssert(opToCancel == PeliasSearchManager.sharedInstance.queuedAutocompleteOp!)
//      opToCancel.cancel()
//    }
//  }

  func testResponseObjectEncoding() {
    let seed: Dictionary = ["SuperSweetKey": "SuperSweetValue"]
    
    let testResponse = PeliasSearchResponse(parsedResponse: seed)
    
    PeliasSearchResponse.encode(testResponse)
    
    let decodedObject = PeliasSearchResponse.decode()
    guard let response = decodedObject?.parsedResponse else { return }
    XCTAssertTrue(testResponse.parsedResponse.elementsEqual(response, by: { (obj1, obj2) -> Bool in
      return obj1.key == obj2.key && obj1.value as? String == obj2.value as? String
    }))
  }

  func testQueryParamsAppended() {
    PeliasSearchManager.sharedInstance.autocompleteTimeDelay = 10.0
    PeliasSearchManager.sharedInstance.urlQueryItems = [URLQueryItem.init(name: "query_item", value: "query_item_value")]
    let point = GeoPoint.init(latitude: 40.0, longitude: 70.0)
    let config = PeliasAutocompleteConfig.init(searchText: "test", focusPoint: point) { (response) in
      //
    }
    _ = PeliasSearchManager.sharedInstance.autocompleteQuery(config)
    _ = PeliasSearchManager.sharedInstance.autocompleteQuery(config)

    let searchUrlStr = PeliasSearchManager.sharedInstance.queuedAutocompleteOp?.config.searchUrl().absoluteString
    XCTAssertTrue((searchUrlStr?.contains("query_item=query_item_value"))!)
    XCTAssertTrue((searchUrlStr?.contains("text=test"))!)
    XCTAssertTrue((searchUrlStr?.contains("focus.point.lat=40.0"))!)
    XCTAssertTrue((searchUrlStr?.contains("focus.point.lon=70.0"))!)
  }

  func testSessionConfiguration() {
    let point = GeoPoint.init(latitude: 40.0, longitude: 70.0)
    let config = PeliasAutocompleteConfig.init(searchText: "test", focusPoint: point) { (response) in
      //
    }
    let operation = PeliasOperation(config: config)

    let sessionConfig = URLSessionConfiguration.ephemeral
    operation.sessionConfig = sessionConfig
    XCTAssertEqual(operation.session.configuration, URLSession.shared.configuration)
    operation.main()
    XCTAssertEqual(operation.session.configuration, sessionConfig)
  }

  func testAddingHttpHeaders() {
    let testHeaders = ["Hello" : "Hi"]
    PeliasSearchManager.sharedInstance.additionalHttpHeaders = testHeaders

    let point = GeoPoint.init(latitude: 40.0, longitude: 70.0)
    let config = PeliasAutocompleteConfig.init(searchText: "test", focusPoint: point) { (response) in
      //
    }
    let testOp = PeliasSearchManager.sharedInstance.autocompleteQuery(config)
    XCTAssertNotNil(testOp.sessionConfig, "Session configuration not created for additional headers")
    guard let sessionheaders = testOp.sessionConfig?.httpAdditionalHeaders else {
      XCTFail("Headers dictionary not created")
      return
    }
    XCTAssertEqual(sessionheaders["Hello"] as? String, testHeaders["Hello"])
  }

}
