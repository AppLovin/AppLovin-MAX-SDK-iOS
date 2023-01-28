//
//  ALMAXSwiftUIBannerAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/26/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import UIKit
import AppLovinSDK

@available(iOS 13.0, *)
class ALMAXSwiftUIBannerAdViewController: UIHostingController<ALMAXSwiftUIBannerAdView>
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, rootView: ALMAXSwiftUIBannerAdView())
    }
}
