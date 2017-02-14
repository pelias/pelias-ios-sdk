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
  
  let PinReuseIdentifier = "pin_loc"

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var searchBox: UITextField!
  
  let manager = CLLocationManager()
  
  let regionRadius: CLLocationDistance = 100
  let initialLocation = CLLocation(latitude: 40.7312973034393, longitude: -73.99896644276561)
  var storedAnnotations: [PeliasMapkitAnnotation]?
  var selectedAnnotation: PeliasMapkitAnnotation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.delegate = self
    // Do any additional setup after loading the view, typically from a nib.
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
      regionRadius * 16.0, regionRadius * 16.0)
    mapView.setRegion(coordinateRegion, animated: true)
    mapView.delegate = self
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.destination.isKind(of: PinDetailVC.self)){
      guard let vc = segue.destination as? PinDetailVC else { return }
      vc.annotation = selectedAnnotation
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

  @IBAction func reverseGeoPressed(_ sender: AnyObject) {
    
    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      manager.requestLocation()
      mapView.showsUserLocation = true
    }

    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }
  
  func performReverseGeo(_ location: CLLocation) {
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
  
  // MARK: - CoreLocation Manager Delegate
  func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus)
  {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      manager.requestLocation()
      mapView.showsUserLocation = true
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    performReverseGeo(locations[0])
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
  // MARK: - Mapview Delegate
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKind(of: MKUserLocation.self) {
      return nil
    }
    
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: PinReuseIdentifier)
    annotationView.canShowCallout = true
    annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let annotation = view.annotation {
      guard let mapAnnotation = annotation as? PeliasMapkitAnnotation else { return }
      self.selectedAnnotation = mapAnnotation
      self.performSegue(withIdentifier: "showPlace", sender: self)
    }
  }
}

