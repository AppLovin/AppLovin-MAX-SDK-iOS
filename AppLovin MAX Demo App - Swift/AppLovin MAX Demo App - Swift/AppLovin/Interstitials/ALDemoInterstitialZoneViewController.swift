//
//  ALDemoInterstitialZoneViewController.swift
//  iOS-SDK-Demo-Swift
//
//  Created by Suyash Saxena on 6/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoInterstitialZoneViewController : ALBaseAdViewController
{
    @IBOutlet weak var showButton: UIBarButtonItem!
    
    var ad: ALAd?
    private let interstitialAd = ALInterstitialAd.shared()

    @IBAction func loadInterstitial(_ sender: AnyObject!)
    {
        logCallback()
        ALSdk.shared()?.adService.loadNextAd(forZoneIdentifier: "YOUR_ZONE_ID", andNotify: self)
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

extension ALDemoInterstitialZoneViewController : ALAdLoadDelegate
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

extension ALDemoInterstitialZoneViewController : ALAdDisplayDelegate
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

extension ALDemoInterstitialZoneViewController : ALAdVideoPlaybackDelegate
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
