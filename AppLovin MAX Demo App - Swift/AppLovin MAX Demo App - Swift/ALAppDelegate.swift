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
        
        let barTintColor = UIColor.init(red: 10/255.0, green: 131/255.0, blue: 170/255.0, alpha: 1.0)
        let navigationBarAppearance = UINavigationBar.appearance()
        if #available(iOS 15.0, *)
        {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = barTintColor
            appearance.titleTextAttributes = [.foregroundColor : UIColor.white]
            navigationBarAppearance.standardAppearance = appearance
            navigationBarAppearance.scrollEdgeAppearance = appearance
            navigationBarAppearance.tintColor = .white
        }
        else
        {
            // Fallback on earlier versions
            navigationBarAppearance.isTranslucent = false
            navigationBarAppearance.barTintColor = barTintColor
            navigationBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
            navigationBarAppearance.tintColor = .white
        }
        
        return true
    }
}
