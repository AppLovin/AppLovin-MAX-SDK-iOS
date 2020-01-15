//
//  ALHomeViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALHomeViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func showMediationDebugger(_ sender: UIBarButtonItem!)
    {
        ALSdk.shared()!.showMediationDebugger()
    }
}

