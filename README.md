# Pelias iOS SDK [![CircleCI](https://circleci.com/gh/pelias/pelias-ios-sdk.svg?style=svg)](https://circleci.com/gh/pelias/pelias-ios-sdk)

This is the iOS SDK wrapper and convenience framework to make interacting with a
Pelias Geocoder instance (https://github.com/pelias/pelias) easier / faster /
more better for iOS developers.

### Recommended Installation Method

We recommend using CocoaPods (https://cocoapods.org/) to install the SDK. We have
two currently supported subspecs: Core and MapkitExtensions. Core only relies on
Foundation being available. MapkitExtensions relies on CoreLocation, MapKit, and
the iOS 9.0+ Contacts Framework being available (and will add these to your project
if you install using CocoaPods).

### Example Usage
Here are some examples which show how easy it is to use the SDK. Be sure to read the [documentation](http://cocoadocs.org/docsets/Pelias/1.0.0/) to see all the properties you can customize when making requests.

#### Search
Find a place by searching for an address or name:

```swift
let text = "cafe"
let config = PeliasSearchConfig(searchText: text, completionHandler: { (searchResponse) -> Void in
  let responseDictionary = searchResponse.parsedResponse?.parsedResponse
  // update UI based on responseDictionary
})
_ = PeliasSearchManager.sharedInstance.performSearch(config)
```

#### Autocomplete
Get real-time result suggestions with autocomplete:

```swift
let text = "cafe"
let point = GeoPoint.init(latitude: 40.74433, longitude: -73.9903)
let config = PeliasAutocompleteConfig(searchText: text, focusPoint: point, completionHandler: { (searchResponse) -> Void in
  let responseDictionary = searchResponse.parsedResponse?.parsedResponse
   // update UI based on responseDictionary
})
_ = PeliasSearchManager.sharedInstance.autocompleteQuery(config)
```

#### Reverse
Find what is located at a certain coordinate location:

```swift
let point = GeoPoint.init(latitude: 40.74433, longitude: -73.9903)
let config = PeliasReverseConfig(point: point, completionHandler: { (searchResponse) -> Void in
  let responseDictionary = searchResponse.parsedResponse?.parsedResponse
  // update UI based on responseDictionary
})
_ = PeliasSearchManager.sharedInstance.reverseGeocode(config)
```

#### Place
Get rich details about a place:

```swift
let gids = ["gid", "anotherGid"]
let config = PeliasPlaceConfig(gids: gids, completionHandler: { (searchResponse) -> Void in
  let responseDictionary = searchResponse.parsedResponse?.parsedResponse
  // update UI based on responseDictionary
})
_ = PeliasSearchManager.sharedInstance.placeQuery(config)
```
### Sample App
The SDK ships with a [sample app](https://github.com/pelias/pelias-ios-sdk/tree/master/SampleApp) which you can run directly within XCode

### Reporting Issues
We welcome issues to be reported using the Github Issue tracker. However please
review the currently open issues before reporting a bug to avoid issue tracker churn.

### Contributing
Please send any and all PRs you want! We do enforce good test coverage,
so please make sure all your new code is covered, and that tests pass locally before
submitting a pull request! 

### Changelog
Please refer to the CHANGES.md document for major change history of the SDK.
