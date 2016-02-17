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

class SecondViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var searchBox: UITextField!
  
  let manager = CLLocationManager()
  
  let regionRadius: CLLocationDistance = 100
  let initialLocation = CLLocation(latitude: 40.7312973034393, longitude: -73.99896644276561)
  var storedAnnotations: [PeliasMapkitAnnotation]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.delegate = self
    // Do any additional setup after loading the view, typically from a nib.
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
      regionRadius * 16.0, regionRadius * 16.0)
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.delegate = self
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
  
  //Mapview Delegate
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKindOfClass(MKUserLocation) {
      return nil
    }
    
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin_loc")
    annotationView.canShowCallout = true
    annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let annotation = view.annotation {
      guard let mapAnnotation = annotation as? PeliasMapkitAnnotation else { return }
      guard let queryItem = PeliasPlaceQueryItem(annotation: mapAnnotation, layer: LayerFilter.address) else { return }
      
      let config = PeliasPlaceConfig(places: [queryItem], completionHandler: { (response) -> Void in
        print(response)
      })
      PeliasSearchManager.sharedInstance.placeQuery(config)
    }
  }
}

