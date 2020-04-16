//
//  ALDemoBannerZoneViewController.swift
//  iOS-SDK-Demo-Swift
//
//  Created by Suyash Saxena on 6/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoBannerZoneViewController : ALBaseAdViewController
{
    let kBannerHeight: CGFloat = 50
    
    private let adView = ALAdView(size: ALAdSize.banner, zoneIdentifier: "YOUR_ZONE_ID")
    @IBOutlet weak var loadButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Optional: Implement the ad delegates to receive ad events.
        adView.adLoadDelegate = self
        adView.adDisplayDelegate = self
        adView.adEventDelegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        // Call loadNextAd() to start showing ads
        adView.loadNextAd()
        
        // Center the banner and anchor it to the bottom of the screen.
        view.addSubview(adView)
        view.addConstraints([
            constraint(with: adView, attribute: .leading),
            constraint(with: adView, attribute: .trailing),
            constraint(with: adView, attribute: .bottom),
            NSLayoutConstraint(item: adView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: kBannerHeight)
            ])
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        adView.adLoadDelegate = nil
        adView.adDisplayDelegate = nil
        adView.adEventDelegate = nil
    }
    
    private func constraint(with adView: ALAdView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint
    {
        return NSLayoutConstraint(item: adView,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: attribute,
                                  multiplier: 1.0,
                                  constant: 0.0)
    }
    
    @IBAction func loadNextAd()
    {
        adView.loadNextAd()
        
        loadButton.isEnabled = false
    }
}

extension ALDemoBannerZoneViewController : ALAdLoadDelegate
{
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()
    }
    
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        // Look at ALErrorCodes.h for list of error codes
        logCallback()

        loadButton.isEnabled = true
    }
}

extension ALDemoBannerZoneViewController : ALAdDisplayDelegate
{
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView)
    {
        logCallback()

        loadButton.isEnabled = true
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

extension ALDemoBannerZoneViewController : ALAdViewEventDelegate
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
