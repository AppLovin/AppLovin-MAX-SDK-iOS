//
//  ALDemoInterstitialManualLoadingViewController.swift
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/25/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoInterstitialManualLoadingViewController : ALBaseAdViewController
{
    @IBOutlet weak var showButton: UIBarButtonItem!
    
//revisit
    private var ad: ALAd?
    private let interstitialAd = ALInterstitialAd.shared()

    @IBAction func loadInterstitial(_ sender: AnyObject!)
    {
        logCallback()
        ALSdk.shared()!.adService.loadNextAd(ALAdSize.interstitial, andNotify: self)
    }
    
    @IBAction func showInterstitial(_ sender: AnyObject!)
    {
        if let ad = self.ad
        {
            // Optional: Assign delegates
            interstitialAd.adDisplayDelegate = self
            interstitialAd.adVideoPlaybackDelegate = self
            
            interstitialAd.show(ad)
            
            logCallback()
        }
    }
}

extension ALDemoInterstitialManualLoadingViewController : ALAdLoadDelegate
{
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()

        self.ad = ad
        self.showButton.isEnabled = true
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        // Look at ALErrorCodes.h for list of error codes
        logCallback()
    }
}

extension ALDemoInterstitialManualLoadingViewController : ALAdDisplayDelegate
{
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView)
    {
        logCallback()
    }
}

extension ALDemoInterstitialManualLoadingViewController : ALAdVideoPlaybackDelegate
{
    func videoPlaybackBegan(in ad: ALAd)
    {
        logCallback()
    }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool)
    {
        logCallback()
    }
}
