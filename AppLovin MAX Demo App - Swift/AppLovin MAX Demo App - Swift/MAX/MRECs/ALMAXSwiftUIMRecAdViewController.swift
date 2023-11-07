//
//  ALMAXSwiftUIMRecAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/27/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import SwiftUI
import UIKit

@available(iOS 13.0, *)
class ALMAXSwiftUIMRecAdViewController: UIHostingController<ALMAXSwiftUIMRecAdView>
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, rootView: ALMAXSwiftUIMRecAdView())
    }
}
