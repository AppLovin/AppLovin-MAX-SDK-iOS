//
//  ALInterfaceBuilderMrecAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 1/23/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALInterfaceBuilderMrecAdViewController: ALBaseAdViewController, MAAdViewAdDelegate
{
    @IBOutlet weak var adView: MAAdView!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // NOTE: MRECs will be supported in Android SDK 9.12.0 & iOS SDK 6.12.0
        
        // NOTE: Must set Storyboard "User Defined Runtime Attributes" for MREC ad view
        // Key Path = ad_unit_id & ad_format
        // Type     = String
        // Value    = YOUR_AD_UNIT_ID & MREC
        
        // Load the first ad
        adView.loadAd()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) { logCallback() }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withErrorCode errorCode: Int) { logCallback() }

    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didFail(toDisplay ad: MAAd, withErrorCode errorCode: Int) { logCallback() }
    
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
}
