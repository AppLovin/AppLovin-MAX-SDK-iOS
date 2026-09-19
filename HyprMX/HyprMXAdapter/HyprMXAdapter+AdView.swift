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

        let adView = HyprMXBannerView(placementName: placementId, adSize: adFormat.hyprMXAdSize)
        adView.placementDelegate = adViewDelegate

        self.adView = adView
        
        adView.loadAd() { success in
            
            guard success else
            {
                self.log(adEvent: .loadFailed(error: .noFill), id: placementId, adFormat: adFormat)
                delegate.didFailToLoadAdViewAdWithError(.noFill)
                return
            }
            
            self.log(adEvent: .loaded, id: placementId, adFormat: adFormat)
            delegate.didLoadAd(forAdView: adView)
        }
    }
}

final class HyprMXAdViewAdapterDelegate: AdViewAdapterDelegate<HyprMXAdapter>, HyprMXBannerDelegate
{
    func adImpression(_ bannerView: HyprMXBannerView)
    {
        log(adEvent: .displayed, id: bannerView.placementName)
        delegate?.didDisplayAdViewAd()
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
