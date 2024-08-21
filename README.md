# AppLovin MAX SDK

Welcome to the AppLovin MAX SDK, your gateway to unlocking the full potential of in-app monetization.

MAX features a unified auction, premium demand, and customization options allowing you to maximize revenue from in-app advertising. With support for 25+ ad networks and custom integrations, MAX makes it easy to drive higher CPMs and optimize your monetization strategy. 
Learn [more about MAX](https://www.applovin.com/max/) on the AppLovin website.

This `AppLovin-MAX-SDK-iOS` repository contains:
1. Example source code for using MAX
2. Open source mediation adapters

## Examples
### Demo App
The [Swift Demo App](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift) and [Objective-C Demo App](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC) are sample projects demonstrating how to mediate ads using AppLovin MAX. To get started with the demo apps, follow the instructions below:

1. Open a Terminal window in the directory of the desired project: `AppLovin MAX Demo App - Swift` or `AppLovin MAX Demo App - ObjC`.
2. Install the latest SDK with CocoaPods using `pod install --repo-update`.
3. Open the newly generated Xcode workspace file using `YOUR_PROJECT_NAME.xcworkspace`.
4. Update the `AppLovinSdkKey` value in the `Info.plist` file with the Applovin SDK key associated with your account.
5. Update the bundle identifier with your own unique identifier associated with the application you will create (or already created, if it is an existing app) in the MAX dashboard.
6. Update the unique MAX ad unit id value within the view controller code. Each ad format will correspond to a unique MAX ad unit ID you created in the Applovin dashboard for the bundle id used before.

<img src="https://github.com/user-attachments/assets/b8f67b25-dfb8-4443-82dc-d57f1ecf2eeb" height="500" />

### Demo Ad Formats
The Swift/Obj-C demo apps have examples of implementing the following ad formats.
|   |   |   |
|---|---|---|
| App Open     | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/App%20Open%20Ads) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/App%20Open%20Ads) |
| Banner       | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Banners) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Banners) |
| Interstitial | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Interstitials) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Interstitials) |
| MREC         | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/MRECs) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/MRECs) |
| Native       | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Native%20Ads) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Native%20Ads) |
| Rewarded     | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Rewarded) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Rewarded) |

## Mediation Adapters
There are 25+ open source adapters mediating with the AppLovin SDK. A [list of adapters](https://www.applovin.com/partners/) are available on our AppLovin partners page, filtered by MAX monetization partner.

## Getting Started
Ready to get started? Refer to our [documentation](https://developers.applovin.com/en/ios/overview/integration) for step-by-step guides on integrating MAX and enabling mediated networks in your app.

## GitHub Issue Tracker
To file bugs, make feature requests, or suggest improvements for MAX, please use [GitHub's issue tracker](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/issues).

For questions or further support, please contact us via our [AppLovin support page](https://monetization-support.applovin.com/hc/en-us).
