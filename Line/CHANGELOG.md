# Changelog

## 2.4.20211004.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Fix UI thread warnings by running ad view and native ad creation and loads on main thread.
* Fix potential media view resizing by setting content mode explicitly.

## 2.4.20211004.2
* Fix icon view never getting registered for interaction.

## 2.4.20211004.1
* Add support for native custom ads and updated native template ad support.

## 2.4.20211004.0
* Certified with Line SDK 2.4.20211004.
* Replace `FADDelegate` with `FADLoadDelegate` and `FADAdViewEventListener`.
* Add `didFailedToShowAdWithError` for display failure.
* Update error codes.

## 2.3.20210326.3
* Fix issue causing native ads to time out.

## 2.3.20210326.2
* Initial support for true native ads.

## 2.3.20210326.1
* Always mute banner and MREC ads.

## 2.3.20210326.0
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.
* Update dependency to point to LINE's public pod `FiveAd`.
  
## 2020.12.22.0
* Initial commit.
