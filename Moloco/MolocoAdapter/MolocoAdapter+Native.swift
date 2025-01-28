//
//  MolocoAdapter+Native.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 2/28/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@available(iOS 13.0, *)
extension MolocoAdapter: MANativeAdAdapter
{
    func loadNativeAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MANativeAdAdapterDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard #available(iOS 13.0, *) else
        {
            log(customEvent: .unsupportedMinimumOS)
            delegate.didFailToLoadNativeAdWithError(.unspecified)
            return
        }
        
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: .native)
        
        updatePrivacyStates(for: parameters)
        
        Task {
            nativeAdDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
            nativeAd = await Moloco.shared.createNativeAd(for: placementId, delegate: nativeAdDelegate)
            guard let nativeAd else
            {
                log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: .native)
                delegate.didFailToLoadNativeAdWithError(.invalidConfiguration)
                return
            }
            
            await nativeAd.load(bidResponse: parameters.bidResponse)
        }
    }
}

@available(iOS 13.0, *)
final class MolocoNativeAdapterDelegate: NativeAdAdapterDelegate<MolocoAdapter>, MolocoNativeAdDelegate
{
    func didLoad(ad: MolocoAd)
    {
        guard let nativeAd = adapter.nativeAd else
        {
            logError("[\(adIdentifier)] Native ad is nil")
            delegate?.didFailToLoadNativeAdWithError(.invalidConfiguration)
            return
        }
        
        guard nativeAd.isReady else
        {
            adapter.log(adEvent: .notReady, adFormat: adFormat)
            delegate?.didFailToLoadNativeAdWithError(.adNotReady)
            return
        }
        
        log(adEvent: .loaded)
        
        guard let assets = nativeAd.assets, !assets.title.isEmpty else
        {
            log(adEvent: .missingRequiredAssets)
            delegate?.didFailToLoadNativeAdWithError(.missingRequiredNativeAdAssets)
            return
        }
        
        let maxNativeAd = MAMolocoNativeAd(adapter: adapter, adFormat: adFormat) { builder in
            builder.title = assets.title
            builder.body = assets.description
            builder.advertiser = assets.sponsorText
            builder.callToAction = assets.ctaTitle
            builder.icon = assets.appIcon.map { .init(image: $0) }
            builder.starRating = assets.rating as NSNumber
            builder.mediaView = assets.videoView ?? UIImageView(image: assets.mainImage)
            builder.mainImage = assets.mainImage.map { .init(image: $0) }
        }
        
        delegate?.didLoadAd(for: maxNativeAd, withExtraInfo: nil)
    }
    
    func failToLoad(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoNativeAdapterError ?? error?.molocoAdapterError ?? .unspecified
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadNativeAdWithError(adapterError)
    }
    
    func didHandleImpression(ad: MolocoAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayNativeAd(withExtraInfo: nil)
    }
    
    func failToShow(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoNativeAdapterError ?? error?.molocoAdapterError ?? .unspecified
        log(adEvent: .displayFailed(error: adapterError))
    }
    
    func didHandleClick(ad: MolocoAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickNativeAd()
    }
    
    func didHide(ad: MolocoAd)
    {
        log(adEvent: .hidden)
    }
    
    // Deprecated Delegate Methods
    func didShow(ad: MolocoAd) { }
    func didClick(on ad: MolocoAd) { }
}
