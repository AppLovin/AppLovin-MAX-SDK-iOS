//
//  ALMAXTemplateNativeAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Billy Hu on 1/20/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import Adjust
import AppLovinSDK

class ALMAXTemplateNativeAdViewController: ALBaseAdViewController, MAAdRevenueDelegate
{
    @IBOutlet weak var nativeAdContainerView: UIView!
    
    private var nativeAdLoader: MANativeAdLoader!
    private var nativeAd: MAAd?
    private var nativeAdView: UIView?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: "YOUR_AD_UNIT")
        nativeAdLoader.placement = "Native Template Test Placement"
        nativeAdLoader.setExtraParameterForKey("test_extra_key", value: "test_extra_value")
        nativeAdLoader.nativeAdDelegate = self
        nativeAdLoader.revenueDelegate = self
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        // Clean up any pre-existing native ad
        if let currentNativeAd = nativeAd
        {
            nativeAdLoader.destroy(currentNativeAd)
        }

        if let currentNativeAdView = nativeAdView
        {
            currentNativeAdView.removeFromSuperview()
        }

        nativeAdLoader.loadAd()
    }
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)!
        adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
        adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
        adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
        if let placement = ad.placement
        {
            adjustAdRevenue.setAdRevenuePlacement(placement)
        }
            
        Adjust.trackAdRevenue(adjustAdRevenue)
    }
}

extension ALMAXTemplateNativeAdViewController: MANativeAdDelegate
{
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView, for ad: MAAd) 
    {
        logCallback()
        
        // Save ad for clean up
        nativeAd = ad

        // Add ad view to view
        nativeAdView = maxNativeAdView
        nativeAdContainerView.addSubview(maxNativeAdView)

        maxNativeAdView.translatesAutoresizingMaskIntoConstraints = false

        // Set ad view to span width and height of container and center the ad
        nativeAdContainerView.widthAnchor.constraint(equalTo: maxNativeAdView.widthAnchor).isActive = true
        nativeAdContainerView.heightAnchor.constraint(equalTo: maxNativeAdView.heightAnchor).isActive = true
        nativeAdContainerView.centerXAnchor.constraint(equalTo: maxNativeAdView.centerXAnchor).isActive = true
        nativeAdContainerView.centerYAnchor.constraint(equalTo: maxNativeAdView.centerYAnchor).isActive = true
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        logCallback()
    }
    
    func didClickNativeAd(_ ad: MAAd) 
    {
        logCallback()
    }
}
