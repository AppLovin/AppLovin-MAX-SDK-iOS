//
//  ALDemoInterstitialSingleInstanceViewController.swift
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/25/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoInterstitialBasicIntegrationViewController : ALBaseAdViewController
{
//    @IBOutlet weak var showButton: UIBarButtonItem!
    
    @IBOutlet weak var showButton: UIButton!
    
    private let interstitialAd = ALInterstitialAd.shared()

    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        interstitialAd.adLoadDelegate = self
        interstitialAd.adDisplayDelegate = self
        interstitialAd.adVideoPlaybackDelegate = self
    }
    
    // MARK: IB Action Methods
    
    @IBAction func showInterstitial(_ sender: AnyObject!)
    {
        self.showButton.isEnabled = false
        
        logCallback()
        interstitialAd.show()
    }
}

extension ALDemoInterstitialBasicIntegrationViewController : ALAdLoadDelegate
{
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()
        self.showButton.isEnabled = true
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        logCallback()
        self.showButton.isEnabled = true
    }
}

extension ALDemoInterstitialBasicIntegrationViewController : ALAdDisplayDelegate
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

extension ALDemoInterstitialBasicIntegrationViewController : ALAdVideoPlaybackDelegate
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
