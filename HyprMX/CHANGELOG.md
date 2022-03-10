# Changelog

## 6.0.1.2
* Add support for GDPR.

## 6.0.1.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 6.0.1.0
* Certified with HyprMX SDK 6.0.1.

## 6.0.0.1
* Add support for banners, leaders, MRECs.
* Better mapping of fullscreen ad display errors.

## 6.0.0.0
* Certified with HyprMX SDK 6.0.0.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 5.4.5.0
* Certified with HyprMX SDK 5.4.5.
* Fix memory leak with `initializationDelegate` since `+[MAAdapter destroy]` is not called for adapters used for initializing SDKs.
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.

## 5.4.3.2
* Added error code for when SDK is not initialized in `adNotAvailableForPlacement:` callback.

## 5.4.3.1
* Updated podspec to use `HyprMX/Core` instead of plain `HyprMx`.

## 5.4.3.0
* Certified with HyprMX SDK 5.4.3.

## 5.4.2.1
* Fix userID being null.

## 5.4.2.0
* Initial commit.
