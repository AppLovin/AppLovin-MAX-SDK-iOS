//
//  UnityAdsAdapter+AdView.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import UnityAds

extension UnityAdsAdapter: MAAdViewAdapter
{
    func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        log(adEvent: .loading(isBidding: parameters.isBidding), adFormat: adFormat)
        
        updatePrivacyConsent(for: parameters)
        
        // Every ad needs a random ID associated with each load and show
        biddingAdIdentifier = NSUUID().uuidString
        
        adViewDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
        bannerAdView = UADSBannerView(placementId: placementId, size: adFormat.unityAdSize)
        
        bannerAdView?.delegate = adViewDelegate
        bannerAdView?.load(with: parameters.unityAdLoadOptions(with: biddingAdIdentifier))
    }
}

final class UnityAdsAdViewAdapterDelegate: AdViewAdapterDelegate<UnityAdsAdapter>, UADSBannerViewDelegate
{
    func bannerViewDidLoad(_ bannerView: UADSBannerView!)
    {
        log(adEvent: .loaded)
        delegate?.didLoadAd(forAdView: bannerView)
    }
    
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!)
    {
        log(adEvent: .loadFailed(error: error.unityAdsAdapterError))
        delegate?.didFailToLoadAdViewAdWithError(error.unityAdsAdapterError)
    }
    
    func bannerViewDidShow(_ bannerView: UADSBannerView!)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayAdViewAd()
    }
    
    func bannerViewDidClick(_ bannerView: UADSBannerView!)
    {
        log(adEvent: .clicked)
        delegate?.didClickAdViewAd()
    }
    
    func bannerViewDidLeaveApplication(_ bannerView: UADSBannerView!)
    {
        log(customEvent: .userLeftApplication)
    }
}

fileprivate extension MAAdFormat
{
    var unityAdSize: CGSize
    {
        switch self
        {
        case .banner:
            return CGSize(width: 320, height: 50)
        case .mrec:
            return CGSize(width: 300, height: 250)
        case .leader:
            return CGSize(width: 728, height: 90)
        default:
            assertionFailure("Unsupported ad format: \(self)")
            return CGSize(width: 320, height: 50)
        }
    }
}
