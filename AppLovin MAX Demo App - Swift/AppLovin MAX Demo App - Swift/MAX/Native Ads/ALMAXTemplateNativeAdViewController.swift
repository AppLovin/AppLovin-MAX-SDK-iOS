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

class ALMAXTemplateNativeAdViewController: ALBaseAdViewController
{
    @IBOutlet weak var nativeAdContainerView: UIView!
    
    private let nativeAdLoader: MANativeAdLoader = MANativeAdLoader(adUnitIdentifier: "YOUR_AD_UNIT")
    
    private var nativeAdView: UIView?
    private var nativeAd: MAAd?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nativeAdLoader.nativeAdDelegate = self
        nativeAdLoader.revenueDelegate = self
    }
    
    deinit
    {
        cleanUpAdIfNeeded()
        
        nativeAdLoader.nativeAdDelegate = nil
        nativeAdLoader.revenueDelegate = nil
    }
    
    func cleanUpAdIfNeeded()
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
    }
    
    // MARK: IB Actions
    
    @IBAction func showAd()
    {
        cleanUpAdIfNeeded()
        
        nativeAdLoader.loadAd()
    }
}

extension ALMAXTemplateNativeAdViewController: MANativeAdDelegate
{
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd)
    {
        logCallback()
        
        // Save ad for clean up
        nativeAd = ad
        
        if let adView = maxNativeAdView
        {
            // Add ad view to view
            nativeAdView = adView
            nativeAdContainerView.addSubview(adView)
            
            // Set to false if modifying constraints after adding the ad view to your layout
            adView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set ad view to span width and height of container and center the ad
            nativeAdContainerView.widthAnchor.constraint(equalTo: adView.widthAnchor).isActive = true
            nativeAdContainerView.heightAnchor.constraint(equalTo: adView.heightAnchor).isActive = true
            nativeAdContainerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            nativeAdContainerView.centerYAnchor.constraint(equalTo: adView.centerYAnchor).isActive = true
        }
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
    }
    
    func didClickNativeAd(_ ad: MAAd)
    {
        logCallback()
    }
}

extension ALMAXTemplateNativeAdViewController: MAAdRevenueDelegate
{
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
