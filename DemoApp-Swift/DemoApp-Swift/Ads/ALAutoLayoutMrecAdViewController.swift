//
//  ALAutoLayoutMrecAdViewController.swift
//  DemoApp-Swift
//
//  Created by Andrew Tian on 1/13/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

import UIKit
import AppLovinSDK

class ALAutoLayoutMrecAdViewController: ALBaseAdViewController, MAAdViewAdDelegate
{
    private let adView = MAAdView(adUnitIdentifier: "YOUR_AD_UNIT_ID", adFormat: MAAdFormat.mrec)
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        adView.delegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set background or background color for MRECs to be fully functional
        adView.backgroundColor = .black
        
        view.addSubview(adView)
        
        // Center the MREC and anchor it to the top of the screen.
        adView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        adView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        adView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        adView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        // Load the first ad
        adView.loadAd()
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) { logCallback() }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withErrorCode errorCode: Int) { logCallback() }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didFail(toDisplay ad: MAAd, withErrorCode errorCode: Int) { logCallback() }
    
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
}
