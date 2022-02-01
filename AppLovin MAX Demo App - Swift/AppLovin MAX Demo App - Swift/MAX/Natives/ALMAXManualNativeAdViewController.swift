//
//  ALMAXManualNativeAdViewController.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Billy Hu on 1/20/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

import UIKit
import Adjust
import AppLovinSDK

class ALMAXManualNativeAdViewController: ALBaseAdViewController, MAAdRevenueDelegate
{
    @IBOutlet weak var nativeAdContainerView: UIView!
    
    private var nativeAdLoader: MANativeAdLoader!
    private var nativeAdView: MANativeAdView!
    private var nativeAd: MAAd?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nativeAdViewNib = UINib(nibName: "NativeCustomAdView", bundle: Bundle.main)
        
        nativeAdView = nativeAdViewNib.instantiate(withOwner: nil, options: nil).first! as! MANativeAdView?
        
        let adViewBinder = MANativeAdViewBinder(builderBlock: { (builder) in
            builder.titleLabelTag = 1001
            builder.advertiserLabelTag = 1002
            builder.bodyLabelTag = 1003
            builder.iconImageViewTag = 1004
            builder.optionsContentViewTag = 1005
            builder.mediaContentViewTag = 1006
            builder.callToActionButtonTag = 1007
        })
        nativeAdView.bindViews(with: adViewBinder)
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: "YOUR_AD_UNIT")
        nativeAdLoader.placement = "Native Custom Test Placement"
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

        nativeAdLoader.loadAd(into: nativeAdView)
    }
    
    // MARK: MAAdRevenueDelegate Protocol
    
    func didPayRevenue(for ad: MAAd) {
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

extension ALMAXManualNativeAdViewController: MANativeAdDelegate
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
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
    }
    
    func didClickNativeAd(_ ad: MAAd)
    {
        logCallback()
    }
}