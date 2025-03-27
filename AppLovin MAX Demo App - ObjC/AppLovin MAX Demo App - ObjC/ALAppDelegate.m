//
//  ALAppDelegate.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALAppDelegate.h"
#import <AdjustSdk/AdjustSdk.h>
#import <AppLovinSDK/AppLovinSDK.h>

@implementation ALAppDelegate

// If you want to test your own AppLovin SDK key, change the value here and update the bundle identifier in the xcodeproj.
static NSString *const YOUR_SDK_KEY = @"05TMDQ5tZabpXQ45_UTbmEGNUtVAzSTzT6KmWQc5_CuWdzccS4DCITZoL3yIWUG3bbq60QC_d4WF28tUC4gVTF";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the initialization configuration
    ALSdkInitializationConfiguration *initConfig = [ALSdkInitializationConfiguration configurationWithSdkKey: YOUR_SDK_KEY builderBlock:^(ALSdkInitializationConfigurationBuilder *builder) {

        builder.mediationProvider = ALMediationProviderMAX;
        
        // Enable test mode by default for the current device.
        NSString *currentIDFV = UIDevice.currentDevice.identifierForVendor.UUIDString;
        if ( currentIDFV.length > 0 )
        {
            builder.testDeviceAdvertisingIdentifiers = @[currentIDFV];
        }
    }];

    // Initialize the SDK with the configuration
    [[ALSdk shared] initializeWithConfiguration: initConfig completionHandler:^(ALSdkConfiguration *sdkConfig) {
        // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
        
        // Initialize Adjust SDK
        ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken: @"{YourAppToken}" environment: ADJEnvironmentSandbox];
        [Adjust initSdk:adjustConfig];
    }];
    
    UIColor *barTintColor = [UIColor colorWithRed: 10/255.0 green: 131/255.0 blue: 170/255.0 alpha: 1.0];
    if ( @available(iOS 15.0, *) )
    {
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navigationBarAppearance configureWithOpaqueBackground];
        navigationBarAppearance.backgroundColor = barTintColor;
        navigationBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        [UINavigationBar appearance].standardAppearance = navigationBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navigationBarAppearance;
        [UINavigationBar appearance].tintColor = UIColor.whiteColor;
    }
    else
    {
        // Fallback on earlier versions
        [UINavigationBar appearance].barTintColor = barTintColor;
        [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        [UINavigationBar appearance].tintColor = UIColor.whiteColor;
    }
    
    return YES;
}

@end
