//
//  ALAppDelegate.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import Adjust
import AppLovinSDK
import DTBiOSSDK
import UIKit

class ALAppDelegate: UIResponder, UIApplicationDelegate
{
    // If you want to test your own AppLovin SDK key, change the value here and update the bundle identifier in the xcodeproj.
    let YOUR_SDK_KEY = "05TMDQ5tZabpXQ45_UTbmEGNUtVAzSTzT6KmWQc5_CuWdzccS4DCITZoL3yIWUG3bbq60QC_d4WF28tUC4gVTF"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // External Amazon integrations must initialize their SDK alongside ours
        DTBAds.sharedInstance().setAppKey("2fef16ec-579e-4840-ad50-eb26ebb07f36")
        DTBAds.sharedInstance().setAdNetworkInfo(DTBAdNetworkInfo(networkName: DTBADNETWORK_MAX))
        DTBAds.sharedInstance().mraidPolicy = DTBMRAIDPolicy.init(rawValue: 4)
        DTBAds.sharedInstance().mraidCustomVersions = ["1.0", "2.0", "3.0"]
        DTBAds.sharedInstance().setLogLevel(DTBLogLevelAll)
        DTBAds.sharedInstance().testMode = true
        
        // Create the initialization configuration
        let initConfig = ALSdkInitializationConfiguration(sdkKey: YOUR_SDK_KEY) { builder in

            builder.mediationProvider = ALMediationProviderMAX
             
            // Enable test mode by default for the current device.
            if let currentIDFV = UIDevice.current.identifierForVendor?.uuidString
            {
                builder.testDeviceAdvertisingIdentifiers = [currentIDFV]
            }
        }

        // Initialize the SDK with the configuration
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            // AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
            
            // Initialize Adjust SDK
            let adjustConfig = ADJConfig(appToken: "{YourAppToken}", environment: ADJEnvironmentSandbox)
            Adjust.appDidLaunch(adjustConfig)
        }
        
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
