//
//  PeliasSearchResponse.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public class PeliasSearchResponse: APIResponse {
  let data: NSData?
  let response: NSURLResponse?
  let error: NSError?
  var parsedResponse: NSDictionary?
  
  init(data: NSData?, response: NSURLResponse?, error: NSError?) {
    self.data = data
    self.response = response
    self.error = error
    parsedResponse = parseData(data)
  }
  
  private func parseData(data: NSData?) -> NSDictionary? {
    let JSONData = data!
    do {
      let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData, options:NSJSONReadingOptions(rawValue: 0))
      guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
        print("Not a Dictionary")
        // put in function
        return nil
      }
      print("JSONDictionary! \(JSONDictionary)")
      return JSONDictionary
    }
    catch let JSONError as NSError {
      print("\(JSONError)")
    }
    return nil
  }
}