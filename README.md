# AppLovin MAX SDK

## Overview
MAX is AppLovin's in-app monetization solution.

MAX offers advertisers equal opportunity to bid simultaneously on each impression in a publisher’s inventory via a single unified auction to drive the highest possible yield. You can read more about it [here](https://www.applovin.com/max-header-bidding).

Please check out our [documentation](https://dash.applovin.com/documentation/mediation/ios/getting-started) to get started on integrating and enabling mediated networks using our guides.

## Getting Started

This repo includes two versions of the demo app: one using Objective-C and the other using Swift.

First, start a Terminal window in the folder for the language you want to use: `DemoApp-ObjC` or `DemoApp-Swift`.

We will be using CocoaPods to manage the AppLovin SDK and any other SDKs used for mediation.  If you do not have CocoaPods, you can install it using `gem`.
```
gem install cocoapods
```
Then, you can install the SDKs specified in the `Podfile`.
```
pod install
```
Now you can open the `xcworkspace` that was created with Xcode.

Before you can see ads in the demo app, you need to set up the project. First, go to the Demo App project file. In the `Info` page, change the value of `AppLovinSdkKey` to your SDK key. Then, on the `Signing & Capabilities` page, change the `Bundle Identifier` to your app's bundle identifier. 

Finally, you need to set the ad unit ids. Go to the view controller for the ad type you want to test and change the `adUnitIdentifier` of the ad object to your ad unit id.

Now you're ready to run the app and see what ads look like. 

## Support
We recommend using GitHub to file issues. For feature requests, improvements, questions or any other integration issues using MAX Mediation by AppLovin, please reach out to your account team and copy devsupport@applovin.com.
