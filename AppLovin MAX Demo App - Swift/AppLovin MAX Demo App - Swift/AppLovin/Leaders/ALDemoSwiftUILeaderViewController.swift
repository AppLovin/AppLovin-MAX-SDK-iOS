//
//  ALDemoSwiftUILeaderViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/9/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import UIKit
import AppLovinSDK

@available(iOS 14.0, *)
class ALDemoSwiftUILeaderViewController: UIHostingController<ALDemoSwiftUILeaderView>
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, rootView: ALDemoSwiftUILeaderView())
    }
}
