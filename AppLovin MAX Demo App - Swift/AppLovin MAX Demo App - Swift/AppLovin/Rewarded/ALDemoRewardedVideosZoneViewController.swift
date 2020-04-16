//
//  ALDemoRewardedVideosZoneViewController.swift
//  iOS-SDK-Demo-Swift
//
//  Created by Suyash Saxena on 6/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoRewardedVideosZoneViewController : ALBaseAdViewController
{
    private var incentivizedInterstitial: ALIncentivizedInterstitialAd!
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        incentivizedInterstitial = ALIncentivizedInterstitialAd(zoneIdentifier: "YOUR_ZONE_ID")
    }
    
    @IBAction func showRewardedVideo()
    {
        // You need to preload each rewarded video before it can be displayed
        if incentivizedInterstitial.isReadyForDisplay
        {
            incentivizedInterstitial.showAndNotify(self)
        }
        else
        {
            preloadRewardedVideo()
        }
    }
    
    // You need to preload each rewarded video before it can be displayed
    @IBAction func preloadRewardedVideo()
    {
        logCallback()
        incentivizedInterstitial.preloadAndNotify(self)
    }
}

extension ALDemoRewardedVideosZoneViewController : ALAdLoadDelegate
{
    // MARK: Ad Load Delegate
    
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        // Look at ALErrorCodes.h for list of error codes
        logCallback()
    }
}

extension ALDemoRewardedVideosZoneViewController : ALAdRewardDelegate
{
    func rewardValidationRequest(for ad: ALAd, didSucceedWithResponse response: [AnyHashable: Any])
    {
        /**
         * AppLovin servers validated the reward. Refresh user balance from your server.  We will also pass the number of coins
         * awarded and the name of the currency. However, ideally, you should verify this with your server before granting it.
         */
        
        // "current" - "Coins", "Gold", whatever you set in the dashboard.
        // "amount" - "5" or "5.00" if you've specified an amount in the UI.
        if let amount = response["amount"] as? NSString, let currencyName = response["currency"] as? NSString
        {
            logCallback()
        }
    }
    
    func rewardValidationRequest(for ad: ALAd, didFailWithError responseCode: Int)
    {
        if responseCode == kALErrorCodeIncentivizedUserClosedVideo
        {
            // Your user exited the video prematurely. It's up to you if you'd still like to grant
            // a reward in this case. Most developers choose not to. Note that this case can occur
            // after a reward was initially granted (since reward validation happens as soon as a
            // video is launched).
        }
        else if responseCode == kALErrorCodeIncentivizedValidationNetworkTimeout || responseCode == kALErrorCodeIncentivizedUnknownServerError
        {
            // Some server issue happened here. Don't grant a reward. By default we'll show the user
            // a UIAlertView telling them to try again later, but you can change this in the
            // Manage Apps UI.
        }
        else if responseCode == kALErrorCodeIncentiviziedAdNotPreloaded
        {
            // Indicates that you called for a rewarded video before one was available.
        }
        
        logCallback()
    }
    
    func rewardValidationRequest(for ad: ALAd, didExceedQuotaWithResponse response: [AnyHashable: Any])
    {
        // Your user has already earned the max amount you allowed for the day at this point, so
        // don't give them any more money. By default we'll show them a UIAlertView explaining this,
        // though you can change that from the Manage Apps UI.
        logCallback()
    }
    
    func rewardValidationRequest(for ad: ALAd, wasRejectedWithResponse response: [AnyHashable: Any])
    {
        // Your user couldn't be granted a reward for this view. This could happen if you've blacklisted
        // them, for example. Don't grant them any currency. By default we'll show them a UIAlertView explaining this,
        // though you can change that from the Manage Apps UI.
        logCallback()
    }
}

extension ALDemoRewardedVideosZoneViewController : ALAdDisplayDelegate
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

extension ALDemoRewardedVideosZoneViewController : ALAdVideoPlaybackDelegate
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
