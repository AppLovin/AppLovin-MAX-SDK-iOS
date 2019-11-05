# AppLovin MAX SDK

## Overview
MAX is AppLovin's in-app monetization solution.

MAX offers advertisers equal opportunity to bid simultaneously on each impression in a publisher’s inventory via a single unified auction to drive the highest possible yield. You can read more about it [here](https://www.applovin.com/max-header-bidding).

Please check out our [documentation](https://dash.applovin.com/documentation/mediation/ios/getting-started) to get started on integrating and enabling mediated networks using our guides.

## Demo Apps
To get started with the demo apps, follow the instructions below:

1. Open a Terminal window in the directory of the desired project: `DemoApp-ObjC` or `DemoApp-Swift`.
2. Install the latest SDK with CocoaPods using `pod install`.
3. Open the newly generated Xcode workspace file using `YOUR_PROJECT_NAME.xcworkspace`.
4. Update the `AppLovinSdkKey` value in the `Info.plist` file with the Applovin SDK key associated with your account.
5. Update the bundle identifier with your own unique identifier associated with the application you will create (or already created, if it is an existing app) in the MAX dashboard.
6. Update the unique MAX ad unit id value within the view controller code. Each ad format will correspond to a unique MAX ad unit ID you created in the Applovin dashboard for the bundle id used before.

## Support
We recommend using GitHub to file issues. For feature requests, improvements, questions or any other integration issues using MAX Mediation by AppLovin, please reach out to your account team and copy devsupport@applovin.com.
