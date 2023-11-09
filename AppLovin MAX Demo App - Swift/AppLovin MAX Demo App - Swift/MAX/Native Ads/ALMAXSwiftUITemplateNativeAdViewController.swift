//
//  ALMAXSwiftUITemplateNativeAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/1/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import SwiftUI
import UIKit

@available(iOS 14.0, *)
class ALMAXSwiftUITemplateNativeAdViewController: UIHostingController<ALMAXSwiftUITemplateNativeAdView>
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, rootView: ALMAXSwiftUITemplateNativeAdView())
    }
}
