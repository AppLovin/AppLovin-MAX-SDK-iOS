//
//  MolocoAdapter+AdView.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/6/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@available(iOS 13.0, *)
extension MolocoAdapter: MAAdViewAdapter
{
    func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "13.0", maxVersion: nil) else
        {
            log(customEvent: .unsupportedMinimumOS)
            delegate.didFailToLoadAdViewAdWithError(.unspecified)
            return
        }
        
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        let isNative = parameters.serverParameters["is_native"] as? Bool ?? false
        
        log(adEvent: .loading(), id: placementId, adFormat: adFormat)
        
        updatePrivacyStates(for: parameters)
        
        if isNative
        {
            Task {
                nativeAdViewAdDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
                nativeAd = await Moloco.shared.createNativeAd(for: placementId, delegate: nativeAdViewAdDelegate)
                guard let nativeAd else
                {
                    log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: adFormat)
                    delegate.didFailToLoadAdViewAdWithError(.invalidConfiguration)
                    return
                }
                
                await nativeAd.load(bidResponse: parameters.bidResponse)
            }
        }
        else
        {
            Task {
                let viewController = await MainActor.run {
                    presentingViewController(for: parameters)
                }
                
                adViewDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
                
                switch adFormat
                {
                case .banner, .leader:
                    adView = await Moloco.shared.createBanner(for: placementId, viewController: viewController, delegate: adViewDelegate)
                case .mrec:
                    adView = await Moloco.shared.createMREC(for: placementId, viewController: viewController, delegate: adViewDelegate)
                default:
                    break
                }
                
                guard let adView else
                {
                    log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: adFormat)
                    delegate.didFailToLoadAdViewAdWithError(.invalidConfiguration)
                    return
                }
                
                await adView.load(bidResponse: parameters.bidResponse)
            }
        }
    }
}

@available(iOS 13.0, *)
final class MolocoAdViewAdapterDelegate: AdViewAdapterDelegate<MolocoAdapter>, MolocoBannerDelegate
{
    func didLoad(ad: MolocoAd)
    {
        guard let adView = adapter.adView else
        {
            log(adEvent: .loadFailed(error: .invalidConfiguration))
            delegate?.didFailToLoadAdViewAdWithError(.invalidConfiguration)
            return
        }
        
        log(adEvent: .loaded)
        delegate?.didLoadAd(forAdView: adView)
    }
    
    func failToLoad(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadAdViewAdWithError(adapterError)
    }
    
    func didShow(ad: MolocoAd)
    {
        // NOTE: Only banners will receive the callback as MRECs are not currently supported
        log(adEvent: .displayed)
        delegate?.didDisplayAdViewAd()
    }
    
    func failToShow(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .displayFailed(error: adapterError))
        delegate?.didFailToDisplayAdViewAdWithError(adapterError)
    }
    
    func didClick(on ad: MolocoAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickAdViewAd()
    }
    
    func didHide(ad: MolocoAd)
    {
        log(adEvent: .hidden)
        delegate?.didHideAdViewAd()
    }
}

@available(iOS 13.0, *)
final class MolocoNativeAdViewAdapterDelegate: NativeAdViewAdapterDelegate<MolocoAdapter>, MolocoNativeAdDelegate
{
    func didLoad(ad: MolocoAd)
    {
        guard let nativeAd = adapter.nativeAd else
        {
            adapter.logError("[\(adIdentifier)] Native \(adFormat.label) ad is nil")
            delegate?.didFailToLoadAdViewAdWithError(.invalidConfiguration)
            return
        }
        
        guard nativeAd.isReady else
        {
            adapter.log(adEvent: .notReady, adFormat: adFormat)
            delegate?.didFailToLoadAdViewAdWithError(.adNotReady)
            return
        }
        
        adapter.log(adEvent: .loaded, adFormat: adFormat)
        
        guard let assets = nativeAd.assets else { return }
        
        adapter.nativeAdViewAd = MAMolocoNativeAd(adapter: adapter, adFormat: adFormat) { builder in
            builder.title = assets.title
            builder.body = assets.description
            builder.advertiser = assets.sponsorText
            builder.callToAction = assets.ctaTitle
            builder.icon = assets.appIcon.map { .init(image: $0) }
            builder.starRating = assets.rating as NSNumber
            builder.mediaView = assets.videoView ?? UIImageView(image: assets.mainImage)
            builder.mainImage = assets.mainImage.map { .init(image: $0) }
        }
        
        let nativeAdView = MANativeAdView(from: adapter.nativeAdViewAd, withTemplate: templateName)
        adapter.nativeAdViewAd?.prepare(forInteractionClickableViews: nativeAdView.clickableViews, withContainer: nativeAdView)
        
        delegate?.didLoadAd(forAdView: nativeAdView)
        nativeAd.handleImpression()
    }
    
    func failToLoad(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoNativeAdapterError ?? error?.molocoAdapterError ?? .unspecified
        adapter.log(adEvent: .loadFailed(error: adapterError), adFormat: adFormat)
        delegate?.didFailToLoadAdViewAdWithError(adapterError)
    }
    
    func didHandleImpression(ad: MolocoAd)
    {
        adapter.log(adEvent: .displayed, adFormat: adFormat)
        delegate?.didDisplayAdViewAd()
    }
    
    func failToShow(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoNativeAdapterError ?? error?.molocoAdapterError ?? .unspecified
        adapter.log(adEvent: .displayFailed(error: adapterError), adFormat: adFormat)
        delegate?.didFailToDisplayAdViewAdWithError(adapterError)
    }
    
    func didHandleClick(ad: MolocoAd)
    {
        adapter.log(adEvent: .clicked, adFormat: adFormat)
        delegate?.didClickAdViewAd()
    }
    
    func didHide(ad: MolocoAd)
    {
        adapter.log(adEvent: .hidden, adFormat: adFormat)
        delegate?.didHideAdViewAd()
    }
    
    // Deprecated Delegate Methods
    func didShow(ad: MolocoAd) { }
    func didClick(on ad: MolocoAd) { }
}
