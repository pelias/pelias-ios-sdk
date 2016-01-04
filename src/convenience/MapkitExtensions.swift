//
//  MapkitExtensions.swift
//  pelias-ios-sdk
//
//  Created by Matt on 1/4/16.
//  Copyright © 2016 Mapzen. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Contacts

/*

Typical search response format is in GeoJSON - http://geojson.org/geojson-spec.html

Example:
{
	"geocoding": {
		"version": "0.1",
		"attribution": "https://search.mapzen.com/v1/attribution",
		"query": {
			"text": "cool",
			"size": 1,
			"private": false
		},
		"engine": {
			"name": "Pelias",
			"author": "Mapzen",
			"version": "1.0"
		},
		"timestamp": 1451940120154
	},
	"type": "FeatureCollection",
	"features": [{
		"type": "Feature",
		"properties": {
			"id": "3577127899",
			"gid": "osm:venue:3577127899",
			"layer": "venue",
			"source": "osm",
			"name": "Cool",
			"country_a": "GRC",
			"country": "Greece",
			"region": "ΚΡΗΤΗ",
			"locality": "Î¡ÎÎÎ¥ÎÎÎÎ",
			"confidence": 0.711,
			"label": "Cool, Î¡ÎÎÎ¥ÎÎÎÎ, Greece"
		},
		"geometry": {
			"type": "Point",
			"coordinates": [24.474645, 35.371769]
		}
	}],
	"bbox": [-98.01126, 32.8000597029494, 67.34516, 56.034896]
}

*/

extension PeliasSearchResponse {
  func parsedMapItems() -> [MKMapItem]? {
    //TODO: This should get refactored into eventually being a real GeoJSON decoder, and split out the MapItem creation
    var mapItems = [MKMapItem]()
    if let jsonDictionary = parsedResponse {
      let featuresArray = jsonDictionary["features"] as! [[String:AnyObject]]
      for feature in featuresArray {
        //Address Dictionary for Placemark Creation
        let featureProperties = feature["properties"] as! [String:AnyObject]
        var addressDictionary = [String:String]()
        addressDictionary[CNPostalAddressCountryKey] = featureProperties["country"] as? String
        
        
        //Coordinate Creation
        let featureGeometry = feature["geometry"] as! [String:AnyObject]
        let geometryPosition = featureGeometry["coordinates"] as! [Double]
        let coordinate = CLLocationCoordinate2DMake(geometryPosition[1], geometryPosition[0])
        
        //MKPlacemark
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        //MKMapItem
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = featureProperties["label"] as? String
        
        mapItems.append(mapItem)
      }
    }
    return mapItems;
  }
}

extension MKMapItem: MKAnnotation {
  public var coordinate: CLLocationCoordinate2D{
    get {
      return self.placemark.coordinate
    }
  }
  
  public var title: String?{
    get {
      return self.name
    }
  }
}
