//
//  PinDetailVC.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 2/22/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import UIKit

class PinDetailVC: UIViewController {

  @IBOutlet var textView: UITextView!
  
  var annotation: PeliasMapkitAnnotation?
    override func viewDidLoad() {
      super.viewDidLoad()
      if let placeAnnotation = annotation, let gid = placeAnnotation.data?[PeliasGIDKey] as? String {
        let config = PeliasPlaceConfig(gids: [gid], completionHandler: { (response) -> Void in
          self.textView.text = NSString.init(format: "%@", response.parsedResponse!.parsedResponse) as String
        })
        _ = PeliasSearchManager.sharedInstance.placeQuery(config)
      }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func doneTapped(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
