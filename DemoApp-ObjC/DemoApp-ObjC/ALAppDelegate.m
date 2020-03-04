//
//  ALAppDelegate.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALAppDelegate.h"
#import <AppLovinSDK/AppLovinSDK.h>

@implementation ALAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning - Make sure to add your AppLovin SDK key in the Info.plist under the "AppLovinSdkKey" key
    
    // Initialize the AppLovin SDK
    [ALSdk shared].mediationProvider = ALMediationProviderMAX;
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
    }];
    
    return YES;
}

@end
