//
//  ALDemoMrecProgrammaticViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Nana Amoah on 11/16/21.
//  Copyright © 2021 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALDemoMrecProgrammaticViewController : ALBaseAdViewController
{
    
    private let mrecAdView = ALAdView(size: .mrec)
    @IBOutlet weak var loadButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Optional: Implement the ad delegates to receive ad events.
        mrecAdView.adLoadDelegate = self
        mrecAdView.adDisplayDelegate = self
        mrecAdView.adEventDelegate = self
        mrecAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Call loadNextAd() to start showing ads
        mrecAdView.loadNextAd()
        
        // Center the MREC and anchor it to the top of the screen.
        view.addSubview(mrecAdView)
        mrecAdView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mrecAdView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        mrecAdView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        mrecAdView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        mrecAdView.adLoadDelegate = nil
        mrecAdView.adDisplayDelegate = nil
        mrecAdView.adEventDelegate = nil
    }
    
    @IBAction func loadNextAd()
    {
        mrecAdView.loadNextAd()
        
        loadButton.isEnabled = false
    }
}

extension ALDemoMrecProgrammaticViewController : ALAdLoadDelegate
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

extension ALDemoMrecProgrammaticViewController : ALAdDisplayDelegate
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

extension ALDemoMrecProgrammaticViewController : ALAdViewEventDelegate
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
