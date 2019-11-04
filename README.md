# AppLovin MAX SDK

## Overview
MAX is AppLovin's in-app monetization solution.

MAX offers advertisers equal opportunity to bid simultaneously on each impression in a publisher’s inventory via a single unified auction to drive the highest possible yield. You can read more about it [here](https://www.applovin.com/max-header-bidding).

Please check out our [documentation](https://dash.applovin.com/documentation/mediation/ios/getting-started) to get started on integrating and enabling mediated networks using our guides.

## Getting Started
### Install the SDK
1. Start a Terminal window in the folder you want to use: `DemoApp-ObjC` or `DemoApp-Swift`.
2. Get the latest SDK using CocoaPods with the command:
```
pod install
```

### Set up the project
3. Open up the `xcworkspace` that was created with Xcode and select the project file.
4. Navigate to the `Info` page, and change the value of `AppLovinSdkKey` to your SDK key. 
5. Navigate to the `Signing & Capabilities` page, and change the `Bundle Identifier` to your app's bundle identifier. 

### Set ad unit identifiers

6. Go through the view controllers you want to test and change the `adUnitIdentifier` of the ad object to your ad unit id.

Now you're ready to run the app and see what ads look like. 

## Support
We recommend using GitHub to file issues. For feature requests, improvements, questions or any other integration issues using MAX Mediation by AppLovin, please reach out to your account team and copy devsupport@applovin.com.
