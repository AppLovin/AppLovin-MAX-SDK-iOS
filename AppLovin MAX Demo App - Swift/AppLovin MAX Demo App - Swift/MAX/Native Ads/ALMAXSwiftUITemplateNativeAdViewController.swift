//
//  ALMAXSwiftUITemplateNativeAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/1/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import UIKit
import AppLovinSDK

@available(iOS 13.0, *)
class ALMAXSwiftUITemplateNativeAdViewController: UIHostingController<ALMAXSwiftUITemplateNativeAdView>
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, rootView: ALMAXSwiftUITemplateNativeAdView())
    }
}
