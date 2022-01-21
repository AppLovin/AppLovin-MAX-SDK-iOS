//
//  ALMAXNativeCustomAdTestViewController.swift
//  Test App
//
//  Created by Santosh Bagadi on 11/9/21.
//  Copyright © 2021 AppLovin Corp. All rights reserved.
//

import Foundation
import AppLovinSDK

class ALMAXTestNativeAdTestViewController: ALBaseAdViewController, MAAdRevenueDelegate
{
    @IBOutlet weak var nativeAdContainerView: UIView!
    
    private var nativeAdLoader: MANativeAdLoader!
    private var nativeAdView: MANativeAdView!
    private var maxNativeAd: MAAd?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nativeAdUnitID = "YOUR_AD_UNIT_ID"
        
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
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: nativeAdUnitID)
        nativeAdLoader.placement = "Native Custom Test Placement"
        nativeAdLoader.setExtraParameterForKey("test_extra_key", value: "test_extra_value")
        nativeAdLoader.nativeAdDelegate = self
        nativeAdLoader.revenueDelegate = self
        
        nativeAdLoader.loadAd(into: nativeAdView)
    }
    
    @IBAction func loadAd()
    {
        nativeAdLoader.loadAd(into: nativeAdView)
    }
    
    func didPayRevenue(for ad: MAAd) {
        logCallback()
    }
}

extension ALMAXTestNativeAdTestViewController: MANativeAdDelegate
{
    func didLoadNativeAd(_ nativeAdView: MANativeAdView, for ad: MAAd)
    {
        logCallback()
        
        // Cleanup any pre-existing native ad to prevent memory leaks.
        if let nativeAd = maxNativeAd
        {
            nativeAdLoader.destroy(nativeAd)
        }
        
        // Save ad for cleanup.
        maxNativeAd = ad
        
        nativeAdContainerView.subviews.forEach({ $0.removeFromSuperview() })
        
        // Add ad view to view.
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdContainerView.addSubview(nativeAdView)
        
        // Set ad view to span width and height of container and center the ad.
        nativeAdContainerView.widthAnchor.constraint(equalTo: nativeAdView.widthAnchor).isActive = true
        nativeAdContainerView.heightAnchor.constraint(equalTo: nativeAdView.heightAnchor).isActive = true
        nativeAdContainerView.centerXAnchor.constraint(equalTo: nativeAdView.centerXAnchor).isActive = true
        nativeAdContainerView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor).isActive = true
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
