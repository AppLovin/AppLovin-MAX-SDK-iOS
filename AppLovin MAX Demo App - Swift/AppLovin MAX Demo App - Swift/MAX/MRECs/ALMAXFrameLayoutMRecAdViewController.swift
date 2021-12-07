//
//  ALMAXFrameLayoutMRecAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 1/23/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

import UIKit
import Adjust
import AppLovinSDK

class ALMAXFrameLayoutMRecAdViewController: ALBaseAdViewController, MAAdViewAdDelegate, MAAdRevenueDelegate
{
    private let adView = MAAdView(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        adView.delegate = self
        adView.revenueDelegate = self
        
        // Dimensions
        let width: CGFloat = 300
        let height: CGFloat = 250
        let x: CGFloat = 0
        let y: CGFloat = 0
        
        adView.frame = CGRect(x: x, y: y, width: width, height: height)
        adView.center.x = self.view.center.x
        
        // Set background or background color for MRECs to be fully functional
        adView.backgroundColor = .black
        
        view.addSubview(adView)
        
        // Load the first ad
        adView.loadAd()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) { logCallback() }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) { logCallback() }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { logCallback() }
        
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)!
        adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
        adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
        adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
        if let placement = ad.placement
        {
            adjustAdRevenue.setAdRevenuePlacement(placement)
        }
            
        Adjust.trackAdRevenue(adjustAdRevenue)
    }
}
