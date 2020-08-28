# AppLovin MAX SDK

## Overview
MAX is AppLovin's in-app monetization solution.

Move beyond the traditional monetization solution and integrate MAX. MAX is a single unbiased auction where advertisers get equal access to all ad inventory and bid simultaneously, which drives more competition and higher CPMs for you. You can read more about it [here](https://www.applovin.com/max-header-bidding).

To request an invite for MAX, apply [here](https://try.applovin.com/applovin-max-application).

Please check out our [documentation](https://dash.applovin.com/documentation/mediation/ios/getting-started) to get started on integrating and enabling mediated networks using our guides.

## Demo Apps
To get started with the demo apps, follow the instructions below:

1. Open a Terminal window in the directory of the desired project: `DemoApp-ObjC` or `DemoApp-Swift`.
2. Install the latest SDK with CocoaPods using `pod install`.
3. Open the newly generated Xcode workspace file using `YOUR_PROJECT_NAME.xcworkspace`.
4. Update the `AppLovinSdkKey` value in the `Info.plist` file with the Applovin SDK key associated with your account.
5. Update the bundle identifier with your own unique identifier associated with the application you will create (or already created, if it is an existing app) in the MAX dashboard.
6. Update the unique MAX ad unit id value within the view controller code. Each ad format will correspond to a unique MAX ad unit ID you created in the Applovin dashboard for the bundle id used before.

## Error Codes
| Code          | Description   |
| ------------- |:-------------:|
| -1            | Indicates an unspecified error with one of the mediated network SDKs. |
| 204           | Indicates that no ads are currently eligible for your device. |
| -1001         | Indicates that the ad request timed out (usually due to poor connectivity). |
| -1009         | Indicates that the device is not connected to the internet (e.g. airplane mode). |
| -5001         | Indicates that the ad failed to load due to various reasons (such as no networks being able to fill). |
| -5201         | Indicates an internal state error with the AppLovin MAX SDK. |

## Support
We recommend using GitHub to file issues. For feature requests, improvements, questions or any other integration issues using MAX Mediation by AppLovin, contact us via our support page https://monetization-support.applovin.com/hc/en-us.

