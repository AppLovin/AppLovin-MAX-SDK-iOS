//
//  ALAppDelegate.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        #warning("Make sure to add your AppLovin SDK key in the Info.plist under the \"AppLovinSDKKey\" key")
        
        // Initialize the AppLovin SDK
        ALSdk.shared()!.mediationProvider = ALMediationProviderMAX
        ALSdk.shared()!.initializeSdk(completionHandler: { configuration in
            // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
        })
        
        return true
    }
}
