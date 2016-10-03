# Pelias iOS SDK [![CircleCI](https://circleci.com/gh/pelias/pelias-ios-sdk.svg?style=svg)](https://circleci.com/gh/pelias/pelias-ios-sdk)

This is the iOS SDK wrapper and convenience framework to make interacting with a
Pelias Geocoder instance (https://github.com/pelias/pelias) easier / faster /
more better for iOS developers.

This SDK is currently in what most developers would refer to as a "Developer Preview",
meaning it works but is under heavily development. As such, it's not production
ready, and it would be unwise to integrate it into a production application.

Please refer to the CHANGES.md document for major change history of the SDK.
### Recommended Installation Method

We recommend using CocoaPods (https://cocoapods.org/) to install the SDK. We have
two currently supported subspecs: Core and MapkitExtensions. Core only relies on
Foundation being available. MapkitExtensions relies on CoreLocation, MapKit, and
the iOS 9.0+ Contacts Framework being available (and will add these to your project
if you install using CocoaPods).

### Reporting Issues
We welcome issues to be reported using the Github Issue tracker. However please
review the currently open issues before reporting a bug to avoid issue tracker churn.

###Contributing
All contributions are welcome, although it may be difficult at this stage of development
as the codebase could rapidly change underneath your pull request and require the
unfortunate chore of rebasing against fresh code.

That said, please send any and all PRs you want! We do enforce good test coverage,
so please make sure all your new code is covered, and that tests pass locally before
submitting a pull request! 
