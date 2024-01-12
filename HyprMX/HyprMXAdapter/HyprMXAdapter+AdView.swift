//
//  HyprMXAdapter+AdView.swift
//  HyprMXAdapter
//
//  Created by Chris Cong on 10/6/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import HyprMX

extension HyprMXAdapter: MAAdViewAdapter
{
    func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: adFormat)
        
        updatePrivacyStates(for: parameters)
        
        adViewDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
        adView = .init(placementName: placementId, adSize: adFormat.hyprMXAdSize)
        adView?.placementDelegate = adViewDelegate
        
        adView?.loadAd()
    }
}

final class HyprMXAdViewAdapterDelegate: AdViewAdapterDelegate<HyprMXAdapter>, HyprMXBannerDelegate
{
    func adDidLoad(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .loaded, id: bannerView.placementName)
        delegate?.didLoadAd(forAdView: bannerView)
        delegate?.didDisplayAdViewAd()
    }

    func adFailed(toLoad bannerView: HyprMXBannerView, error: Error)
    {
        let adapterError = error.hyprMXAdapterError
        log(adEvent: .loadFailed(error: adapterError), id: bannerView.placementName)
        delegate?.didFailToLoadAdViewAdWithError(adapterError)
    }
    
    func adWasClicked(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .clicked, id: bannerView.placementName)
        delegate?.didClickAdViewAd()
    }

    func adDidOpen(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .expanded, id: bannerView.placementName)
        delegate?.didExpandAdViewAd()
    }

    func adDidClose(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .collapsed, id: bannerView.placementName)
        delegate?.didCollapseAdViewAd()
    }

    func adWillLeaveApplication(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .willLeaveApplication, id: bannerView.placementName)
    }
}

fileprivate extension MAAdFormat
{
    var hyprMXAdSize: CGSize
    {
        switch self
        {
        case .banner:
            return kHyprMXAdSizeBanner
        case .mrec:
            return kHyprMXAdSizeMediumRectangle
        case .leader:
            return kHyprMXAdSizeLeaderBoard
        default:
            assertionFailure("Unsupported ad format: \(self)")
            return kHyprMXAdSizeBanner
        }
    }
}
