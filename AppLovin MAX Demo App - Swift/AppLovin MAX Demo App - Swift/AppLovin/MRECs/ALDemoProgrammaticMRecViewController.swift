//
//  ALDemoProgrammaticMRecViewController.swift
//  iOS-SDK-Demo-Swift
//
//  Created by Thomas So on 3/6/17.
//  Copyright © 2017 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoProgrammaticMRecViewController : ALBaseAdViewController
{
    private let kMRecHeight: CGFloat = 250
    private let kMRecWidth: CGFloat = 300
    
    private let adView = ALAdView(size: .mrec)
    
    // MARK: View Lifecycle
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Optional: Implement the ad delegates to receive ad events.
        adView.adLoadDelegate = self
        adView.adDisplayDelegate = self
        adView.adEventDelegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false
        callbackTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Call loadNextAd() to start showing ads
        adView.loadNextAd()
        
        view.addSubview(adView)
        view.addConstraints([
            NSLayoutConstraint(item: callbackTableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: callbackTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: callbackTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
            
            NSLayoutConstraint(item: adView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: adView, attribute: .top, relatedBy: .equal, toItem: callbackTableView, attribute: .bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: adView, attribute: .bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: adView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kMRecHeight),
            NSLayoutConstraint(item: adView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kMRecWidth)
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        adView.adLoadDelegate = nil
        adView.adDisplayDelegate = nil
        adView.adEventDelegate = nil
    }
}

extension ALDemoProgrammaticMRecViewController : ALAdLoadDelegate
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

extension ALDemoProgrammaticMRecViewController : ALAdDisplayDelegate
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

extension ALDemoProgrammaticMRecViewController : ALAdViewEventDelegate
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
