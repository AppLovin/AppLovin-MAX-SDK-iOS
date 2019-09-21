//
//  ALInterstitialAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 9/20/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALInterstitialAdViewController: UIViewController, MAAdViewAdDelegate
{
    private var interstitialAd: MAInterstitialAd?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        interstitialAd = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        guard let interstitialAd = interstitialAd else { return }
        interstitialAd.delegate = self
        
        // Load the first ad
        interstitialAd.load()
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        if let interstitialAd = interstitialAd, interstitialAd.isReady
        {
            interstitialAd.show()
        }
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd)
    {
        // Interstitial ad is ready to be shown. '[self.interstitialAd isReady]' will now return 'YES'
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withErrorCode errorCode: Int)
    {
        // Interstitial ad failed to load. We recommend re-trying in 3 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(3 * Double(NSEC_PER_SEC)), execute: {
            if let interstitialAd = self.interstitialAd
            {
                interstitialAd.load()
            }
        })
    }
    
    func didDisplay(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didExpand(_ ad: MAAd) {}

    func didCollapse(_ ad: MAAd) {}

    func didHide(_ ad: MAAd)
    {
        // Interstitial ad is hidden. Pre-load the next ad
        if let interstitialAd = interstitialAd
        {
            interstitialAd.load()
        }
    }
    
    func didFail(toDisplay ad: MAAd, withErrorCode errorCode: Int)
    {
        // Interstitial ad failed to display. We recommend loading the next ad
        if let interstitialAd = interstitialAd
        {
            interstitialAd.load()
        }
    }
}
