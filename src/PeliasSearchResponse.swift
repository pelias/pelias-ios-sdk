//
//  PeliasSearchResponse.swift
//  PlayMap
//
//  Created by Matt on 11/24/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import Foundation

public struct PeliasSearchResponse {
  let data: NSData?
  let response: NSURLResponse?
  let error: NSError?
  
  init(data: NSData?, response: NSURLResponse?, error: NSError?){
    self.data = data
    self.response = response
    self.error = error
  }
}