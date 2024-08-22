<div align="center">
  <a href="https://www.applovin.com/max/">
    <img src="https://www.applovin.com/wp-content/uploads/2023/06/logo_home_products_max.svg" alt="MAX Logo" height="70"/>
  </a>
</div>

# AppLovin MAX SDK
Welcome to the AppLovin MAX SDK, your gateway to unlocking the full potential of in-app monetization.

MAX features a unified auction, premium demand, and various ad formats. These allow you to maximize revenue from in-app advertising. With support for 25+ ad networks and custom integrations, MAX makes it easy to drive higher CPMs and optimize your monetization strategy. 
Learn [more about MAX](https://www.applovin.com/max/) on the AppLovin website.

This `AppLovin-MAX-SDK-iOS` repository contains:
1. Example source code for using MAX
2. Open source mediation adapters

## Examples
### Demo App
The [Swift Demo App](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift) and [Objective-C Demo App](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC) are sample projects demonstrating how to mediate ads using AppLovin MAX. To get started with the demo apps, follow the instructions below:

1. Open a Terminal window in the directory of the desired project: `AppLovin MAX Demo App - Swift` or `AppLovin MAX Demo App - ObjC`.
2. Install the latest SDK using CocoaPods by issuing the command `pod install --repo-update`.
3. Open the Xcode workspace file that the `pod install` command generates: `YOUR_PROJECT_NAME.xcworkspace`.
4. Change the value of the bundle identifier to your own unique identifier. Base your identifier on the name of the application you will create or that you have already created in the MAX dashboard. To change the bundle identifier value, select **Project > Info** and then edit the **Bundle identifier** value under **Custom iOS Target Properties**.
5. Update the unique MAX ad unit ID value within the view controller code for each ad format located in the **AppLovin MAX Demo App - [Swift\Obj-C] > MAX** folder. Each ad format corresponds to a unique MAX ad unit ID you create in the AppLovin dashboard for your application’s bundle identifier. 

<img src="https://github.com/user-attachments/assets/63763968-ecd3-46bd-a92b-be6f52b0fe28" height="500" />

### Demo Ad Formats
The Swift/Obj-C demo apps have examples of implementing the following ad formats.
| Ad Formats   | Swift | Obj-C |
|--------------|-------|-------|
| App Open     | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/App%20Open%20Ads/ALMAXAppOpenAdViewController.swift) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/App%20Open%20Ads/ALMAXAppOpenAdViewController.m) |
| Banner       | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Banners) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Banners) |
| Interstitial | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Interstitials/ALMAXInterstitialAdViewController.swift) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Interstitials/ALMAXInterstitialAdViewController.m) |
| MREC         | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/MRECs) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/MRECs) |
| Native       | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Native%20Ads) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/tree/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Native%20Ads) |
| Rewarded     | [Swift](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20Swift/AppLovin%20MAX%20Demo%20App%20-%20Swift/MAX/Rewarded/ALMAXRewardedAdViewController.swift) | [Obj-C](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/blob/master/AppLovin%20MAX%20Demo%20App%20-%20ObjC/AppLovin%20MAX%20Demo%20App%20-%20ObjC/MAX/Rewarded/ALMAXRewardedAdViewController.m) |

## Mediation Adapters
The AppLovin SDK mediates 25+ open source adapters. To see the list of these partners, visit the [AppLovin Partners](https://www.applovin.com/partners/) page and select **Partner Type > MAX > Monetization Partner** from the checkboxes in the **Partner Type** drop-down.

## Getting Started with MAX
Ready to get started? Refer to our [documentation](https://developers.applovin.com/en/ios/overview/integration) for step-by-step guides on integrating MAX and enabling mediated networks in your app.

## Feedback & Support
To file bugs, make feature requests, or suggest improvements for MAX, please use [GitHub's issue tracker](https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/issues).

For questions or further support, please contact us via our [AppLovin support page](https://support.applovin.com/hc/en-us).
