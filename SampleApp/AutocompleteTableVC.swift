//
//  AutocompleteTableVC.swift
//  pelias-ios-sdk
//
//  Created by Matt Smollinger on 1/28/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AutocompleteTableVC: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate {
  
  let searchController = UISearchController(searchResultsController: nil)
  var results: [PeliasMapkitAnnotation]?
  let manager = CLLocationManager()
  var currentLocation: CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    self.tableView.tableHeaderView = searchController.searchBar
    self.definesPresentationContext = true
    searchController.searchBar.sizeToFit()
    manager.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      manager.requestLocation()
    }
    
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let unwrappedResults = results {
      return unwrappedResults.count
    }
    return 0
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    if let searchText = searchController.searchBar.text, searchController.searchBar.text?.isEmpty == false {
      var geoPoint = GeoPoint(latitude: 40.7312973034393, longitude: -73.99896644276561)
      if let location = currentLocation {
        geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      }
      let config = PeliasAutocompleteConfig(searchText: searchText, focusPoint: geoPoint, completionHandler: { (autocompleteResponse) -> Void in
        self.results = autocompleteResponse.parsedMapItems()
        self.tableView.reloadData()
      })
      _ = PeliasSearchManager.sharedInstance.autocompleteQuery(config)
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "basicCellIdent", for: indexPath)
    cell.textLabel?.text = results?[indexPath.row].title
    return cell
  }
  
  // CoreLocation Manager Delegate
  func locationManager(_ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus)
  {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      manager.requestLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0]
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchController.searchBar.resignFirstResponder()
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
