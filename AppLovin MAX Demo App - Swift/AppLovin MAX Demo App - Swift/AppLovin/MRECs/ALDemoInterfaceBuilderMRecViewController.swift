//
//  ALDemoInterfaceBuilderMRecViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Varsha Hanji on 4/6/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoInterfaceBuilderMRecViewController : ALBaseAdViewController
{
    
    @IBOutlet weak var adView: ALAdView!
    
    
    // MARK: View Lifecycle
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        adView.adLoadDelegate = self
        adView.adDisplayDelegate = self
        adView.adEventDelegate = self

        adView.adSize = ALAdSize.mrec

        // Call loadNextAd() to start showing ads
        adView.loadNextAd()
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        adView.adLoadDelegate = nil
        adView.adDisplayDelegate = nil
        adView.adEventDelegate = nil
    }
}

extension ALDemoInterfaceBuilderMRecViewController : ALAdLoadDelegate
{
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

extension ALDemoInterfaceBuilderMRecViewController : ALAdDisplayDelegate
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

extension ALDemoInterfaceBuilderMRecViewController : ALAdViewEventDelegate
{
    func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, willDismissFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didReturnToApplicationFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode)
    {
        logCallback()
    }
}
