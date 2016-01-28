//
//  SecondViewController.swift
//  pelias-ios-sdk
//
//  Created by Matt on 11/30/15.
//  Copyright © 2015 Mapzen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SecondViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var searchBox: UITextField!
  
  let manager = CLLocationManager()
  
  let regionRadius: CLLocationDistance = 100
  let initialLocation = CLLocation(latitude: 40.7312973034393, longitude: -73.99896644276561)
  var storedAnnotations: [MKMapItem]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.delegate = self
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
      PeliasSearchManager.sharedInstance.performSearch(searchConfig)
    }
    searchBox.resignFirstResponder()
    return true
  }

  @IBAction func reverseGeoPressed(sender: AnyObject) {
    
    if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
      manager.requestLocation()
      mapView.showsUserLocation = true
    }

    
    if CLLocationManager.authorizationStatus() == .NotDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }
  
  func performReverseGeo(location: CLLocation) {
    let point = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let config = PeliasReverseConfig(point: point) { (response) -> Void in
      if let annotations = response.parsedMapItems(){
        if let currentAnnotations = self.storedAnnotations{
          self.mapView.removeAnnotations(currentAnnotations)
        }
        self.mapView.addAnnotations(annotations)
        self.storedAnnotations = annotations
        //Attempt to center map on first annotation returned
        if (annotations.count > 0) {
          let region = MKCoordinateRegionMake(annotations[0].coordinate, MKCoordinateSpanMake(0.03, 0.03))
          self.mapView.setRegion(region, animated: true)
          self.mapView.regionThatFits(region)
        }
      }
    }
    PeliasSearchManager.sharedInstance.reverseGeocode(config)
  }
  
  // CoreLocation Manager Delegate
  func locationManager(manager: CLLocationManager,
    didChangeAuthorizationStatus status: CLAuthorizationStatus)
  {
    if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
      manager.requestLocation()
      mapView.showsUserLocation = true
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    performReverseGeo(locations[0])
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print(error)
  }
}

