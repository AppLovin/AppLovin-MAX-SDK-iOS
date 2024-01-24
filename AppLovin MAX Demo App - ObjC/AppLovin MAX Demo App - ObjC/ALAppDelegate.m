//
//  ALAppDelegate.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALAppDelegate.h"
#import <Adjust/Adjust.h>
#import <AppLovinSDK/AppLovinSDK.h>

@implementation ALAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // If you want to test your own AppLovin SDK key,
    // update the value in Info.plist under the \"AppLovinSdkKey\" key, and update the package name to your app's name.
    
    // Enable test mode by default for the current device.
    NSString *currentIDFV = UIDevice.currentDevice.identifierForVendor.UUIDString;
    ALSdkSettings *settings = [[ALSdkSettings alloc] init];
    
    if ( currentIDFV && currentIDFV.length > 0 )
    {
        settings.testDeviceAdvertisingIdentifiers = @[currentIDFV];
    }
    
    // Initialize the AppLovin SDK
    ALSdk *sdk = [ALSdk sharedWithSettings: settings];
    sdk.mediationProvider = ALMediationProviderMAX;
    [sdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
        
        // Initialize Adjust SDK
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken: @"{YourAppToken}" environment: ADJEnvironmentSandbox];
        [Adjust appDidLaunch: adjustConfig];
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
