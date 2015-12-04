//
//  FirstViewController.swift
//  pelias-ios-sdk
//
//  Created by Matt on 11/30/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  @IBOutlet weak var searchField: UITextField!
  @IBOutlet weak var responseTextView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func searchTapped(sender: AnyObject) {
    
    if let searchText = searchField.text{
      let searchConfig = PeliasSearchConfig(searchText: searchText, completionHandler: { (searchResponse) -> Void in
        let JSONData = searchResponse.data!
        do {
          let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData, options:NSJSONReadingOptions(rawValue: 0))
          guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
            print("Not a Dictionary")
            // put in function
            return
          }
          print("JSONDictionary! \(JSONDictionary)")
          self.responseTextView.text = NSString.init(format: "%@", JSONDictionary) as String
        }
        catch let JSONError as NSError {
          print("\(JSONError)")
        }
      })
      SearchManager.sharedInstance.performSearch(searchConfig)
    }
  }
}

