//
//  ALMAXAppOpenAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Avi Leung on 2/13/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AdjustSdk
import AppLovinSDK
import UIKit

class ALMAXAppOpenAdViewController: ALBaseAdViewController, MAAdViewAdDelegate, MAAdRevenueDelegate
{
    private let appOpenAd = MAAppOpenAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        appOpenAd.delegate = self
        appOpenAd.revenueDelegate = self
        
        // Load the first ad
        appOpenAd.load()
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        appOpenAd.show()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd)
    {
        // App Open ad is ready to be shown. 'appOpenAd.isReady' will now return 'true'
        logCallback()
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
    }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd)
    {
        logCallback()
        
        // App Open ad is hidden. Pre-load the next ad
        appOpenAd.load()
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError)
    {
        logCallback()
        
        // App Open ad failed to display. We recommend loading the next ad
        appOpenAd.load()
    }
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: "applovin_max_sdk")!
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
