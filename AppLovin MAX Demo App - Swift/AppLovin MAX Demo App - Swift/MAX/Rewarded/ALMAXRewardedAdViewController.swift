//
//  ALMAXRewardedAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import Adjust
import AppLovinSDK

class ALMAXRewardedAdViewController: ALBaseAdViewController, MARewardedAdDelegate, MAAdRevenueDelegate
{
    private let rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: "YOUR_AD_UNIT_ID")
    private var retryAttempt = 0.0
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        rewardedAd.delegate = self
        rewardedAd.revenueDelegate = self
        
        // Load the first ad
        rewardedAd.load()
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        rewardedAd.show()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd)
    {
        // Rewarded ad is ready to be shown. '[self.rewardedAd isReady]' will now return 'YES'
        logCallback()
        
        // Reset retry attempt
        retryAttempt = 0
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
        
        // Rewarded ad failed to load. We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds).
        
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.rewardedAd.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd)
    {
        logCallback()
        
        // Rewarded ad is hidden. Pre-load the next ad
        rewardedAd.load()
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError)
    {
        logCallback()
        
        // Rewarded ad failed to display. We recommend loading the next ad
        rewardedAd.load()
    }
    
    // MARK: MARewardedAdDelegate Protocol
    
    func didStartRewardedVideo(for ad: MAAd) { logCallback() }
    
    func didCompleteRewardedVideo(for ad: MAAd) { logCallback() }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward)
    {
        // Rewarded ad was displayed and user should receive the reward
        logCallback()
    }
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)
        
        guard let adjustAdRevenue = adjustAdRevenue else { return }
        
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
