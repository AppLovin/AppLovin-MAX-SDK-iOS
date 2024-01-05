//
//  MyTargetAdapter+AdView.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 8/17/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

import AppLovinSDK
import MyTargetSDK

extension MyTargetAdapter: MAAdViewAdapter
{
    public func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: adFormat)
        
        guard let slotId = UInt(placementId) else
        {
            log(adEvent: .loadFailed(error: .invalidConfiguration), id: placementId, adFormat: adFormat)
            delegate.didFailToLoadAdViewAdWithError(.invalidConfiguration)
            return
        }
        
        adViewDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
        adView = .init(slotId: slotId, shouldRefreshAd: false)
        adView?.adSize = adFormat.myTargetAdSize
        adView?.delegate = adViewDelegate
        adView?.viewController = presentingViewController(for: parameters)
        adView?.customParams.setCustomParam(Self.mediationParameter.value, forKey: Self.mediationParameter.key)
        
        updatePrivacyStates(for: parameters)
        
        if parameters.isBidding
        {
            adView?.load(fromBid: parameters.bidResponse)
        }
        else
        {
            adView?.load()
        }
    }
}

final class MyTargetAdViewAdapterDelegate: AdViewAdapterDelegate<MyTargetAdapter>, MTRGAdViewDelegate
{
    func onLoad(with adView: MTRGAdView)
    {
        log(adEvent: .loaded)
        delegate?.didLoadAd(forAdView: adView)
    }
    
    func onLoadFailed(error: Error, adView: MTRGAdView)
    {
        let adapterError = error.myTargetAdapterError
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadAdViewAdWithError(adapterError)
    }
    
    func onAdShow(with adView: MTRGAdView)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayAdViewAd()
    }
    
    func onAdClick(with adView: MTRGAdView)
    {
        log(adEvent: .clicked)
        delegate?.didClickAdViewAd()
    }
    
    func onShowModal(with adView: MTRGAdView)
    {
        log(adEvent: .expanded)
        // Don't forward expand/collapse callbacks because they don't always fire dismiss callback for banners displaying StoreKit.
        // delegate.didExpandAdViewAd()
    }
    
    func onDismissModal(with adView: MTRGAdView)
    {
        log(adEvent: .collapsed)
        // Don't forward expand/collapse callbacks because they don't always fire dismiss callback for banners displaying StoreKit.
        // delegate.didCollapseAdViewAd()
    }
    
    func onLeaveApplication(with adView: MTRGAdView)
    {
        log(customEvent: .userLeftApplication)
    }
}

fileprivate extension MAAdFormat
{
    var myTargetAdSize: MTRGAdSize
    {
        switch self
        {
        case .banner:
            return MTRGAdSize.adSize320x50()
        case .mrec:
            return MTRGAdSize.adSize300x250()
        case .leader:
            return MTRGAdSize.adSize728x90()
        default:
            assertionFailure("Unsupported ad format: \(self)")
            return MTRGAdSize.adSize320x50()
        }
    }
}
