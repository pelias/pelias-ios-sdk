# Pelias iOS SDK Release Checklist

## Requirements
- Have Xcode installed
- Have cocoapods installed
- Have ownership privileges to update the cocoapods trunk spec

## Steps
1. Update the Pelias.podspec version number with the version you want to release
2. Update the .swift file with the current version of swift the sdk is compiled against
3. Commit these changes
4. Tag current master with the version you updated the .podspec to and push to github
5. Run `pod spec lint` to make sure everything is happy. Fix issues if not happy (document known issues)
6. Push the updated pod spec to trunk: `pod trunk push Pelias.podspec`
7. Write up release notes and release the SDK on github
