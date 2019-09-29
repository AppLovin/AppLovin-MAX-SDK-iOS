//
//  ALFrameLayoutBannerAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALFrameLayoutBannerAdViewController: UIViewController, MAAdViewAdDelegate
{
    private let adView = MAAdView(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        adView.delegate = self
        
        // Calculate dimensions
        let width = view.bounds.width // Stretch to the width of the screen for banners to be fully functional
        let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50 // Banner height on iPhone and iPad is 50 and 90, respectively
        let x: CGFloat = 0
        let y: CGFloat = 0
        
        adView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Set background or background color for banners to be fully functional
        adView.backgroundColor = .black
        
        view.addSubview(adView)
        
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
