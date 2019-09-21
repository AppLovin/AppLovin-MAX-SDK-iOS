//
//  ALInterfaceBuilderBannerAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALInterfaceBuilderBannerAdViewController: UIViewController, MAAdViewAdDelegate
{
    @IBOutlet weak var adView: MAAdView!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // NOTE: Must set Storyboard "User Defined Runtime Attributes" for banner ad view
        // Key Path = ad_unit_id
        // Type     = String
        // Value    = YOUR_AD_UNIT_ID
        
        // Load the first ad
        adView.loadAd()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) {}
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withErrorCode errorCode: Int) {}
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withErrorCode errorCode: Int) {}
    
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
}
