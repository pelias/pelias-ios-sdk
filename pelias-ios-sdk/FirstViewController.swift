//
//  FirstViewController.swift
//  pelias-ios-sdk
//
//  Created by Matt on 11/30/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var searchField: UITextField!
  @IBOutlet weak var responseTextView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    searchField.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    searchTapped(textField)
    return true
  }

  @IBAction func searchTapped(sender: AnyObject) {
    searchField.resignFirstResponder()
    if let searchText = searchField.text{
      let searchConfig = PeliasSearchConfig(searchText: searchText, completionHandler: { (searchResponse) -> Void in
        self.responseTextView.text = NSString.init(format: "%@", searchResponse.parsedResponse!) as String
      })
      PeliasSearchManager.sharedInstance.performSearch(searchConfig)
    }
  }
}

