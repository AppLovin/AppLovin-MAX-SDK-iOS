//
//  ALAppDelegate.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import Adjust
import AppLovinSDK
import UIKit

class ALAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // If you want to test your own AppLovin SDK key,
        // update the value in Info.plist under the \"AppLovinSdkKey\" key, and update the package name to your app's name.
        
        // Enable test mode by default for the current device.
        let currentIDFV = UIDevice.current.identifierForVendor?.uuidString
        let settings = ALSdkSettings()
        
        if let currentIDFV
        {
            settings.testDeviceAdvertisingIdentifiers = [currentIDFV]
        }
        
        // Initialize the AppLovin SDK
        let sdk = ALSdk.shared(with: settings)!
        sdk.mediationProvider = ALMediationProviderMAX
        sdk.initializeSdk(completionHandler: { configuration in
            // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
            
            // Initialize Adjust SDK
            let adjustConfig = ADJConfig(appToken: "{YourAppToken}", environment: ADJEnvironmentSandbox)
            Adjust.appDidLaunch(adjustConfig)
        })
        
        let barTintColor = UIColor.init(red: 10 / 255.0, green: 131 / 255.0, blue: 170 / 255.0, alpha: 1.0)
        let navigationBarAppearance = UINavigationBar.appearance()
        if #available(iOS 15.0, *)
        {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = barTintColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBarAppearance.standardAppearance = appearance
            navigationBarAppearance.scrollEdgeAppearance = appearance
            navigationBarAppearance.tintColor = .white
        }
        else
        {
            // Fallback on earlier versions
            navigationBarAppearance.isTranslucent = false
            navigationBarAppearance.barTintColor = barTintColor
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBarAppearance.tintColor = .white
        }
        
        return true
    }
}
