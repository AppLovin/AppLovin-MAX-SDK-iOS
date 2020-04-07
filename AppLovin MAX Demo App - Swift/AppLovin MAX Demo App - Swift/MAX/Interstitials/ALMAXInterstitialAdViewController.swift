//
//  ALInterstitialAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALMAXInterstitialAdViewController: ALBaseAdViewController, MAAdViewAdDelegate
{
    private let interstitialAd = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    private var retryAttempt = 0.0
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        interstitialAd.delegate = self
        
        // Load the first ad
        interstitialAd.load()
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        interstitialAd.show()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd)
    {
        // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'
        logCallback()
        
        // Reset retry attempt
        retryAttempt = 0
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withErrorCode errorCode: Int)
    {
        logCallback()
        
        // Interstitial ad failed to load. We recommend retrying with exponentially higher delays.
        
        retryAttempt += 1
        let delaySec = pow(2.0, retryAttempt)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.interstitialAd.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd)
    {
        logCallback()
        
        // Interstitial ad is hidden. Pre-load the next ad
        interstitialAd.load()
    }
    
    func didFail(toDisplay ad: MAAd, withErrorCode errorCode: Int)
    {
        logCallback()
        
        // Interstitial ad failed to display. We recommend loading the next ad
        interstitialAd.load()
    }
}
