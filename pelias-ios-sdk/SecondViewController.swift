//
//  SecondViewController.swift
//  pelias-ios-sdk
//
//  Created by Matt on 11/30/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import UIKit
import MapKit

class SecondViewController: UIViewController, UITextFieldDelegate{

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var searchBox: UITextField!
  
  let regionRadius: CLLocationDistance = 100
  let initialLocation = CLLocation(latitude: 40.7312973034393, longitude: -73.99896644276561)
  var storedAnnotations: [MKMapItem]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
      regionRadius * 16.0, regionRadius * 16.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let searchRect = SearchBoundaryRect(mapRect: mapView.visibleMapRect)
    if let searchText = searchBox.text{
      var searchConfig = PeliasSearchConfig(searchText: searchText, completionHandler: { (searchResponse) -> Void in
        if let annotations = searchResponse.parsedMapItems(){
          if let currentAnnotations = self.storedAnnotations{
            self.mapView.removeAnnotations(currentAnnotations)
          }
          self.mapView.addAnnotations(annotations)
          self.storedAnnotations = annotations
        }
      })
      searchConfig.boundaryRect = searchRect
      SearchManager.sharedInstance.performSearch(searchConfig)
    }
    searchBox.resignFirstResponder()
    return true
  }

}

