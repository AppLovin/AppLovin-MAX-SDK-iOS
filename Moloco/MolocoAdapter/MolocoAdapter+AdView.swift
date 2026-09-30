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
                nativeAd = await Moloco.shared.createNativeAd(params: .init(adUnit: placementId, mediation: "max"))
                nativeAd?.delegate = nativeAdViewAdDelegate
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
                let (viewController, size) = await MainActor.run { () -> (UIViewController, MolocoBannerAdSize) in
                    (presentingViewController(for: parameters), molocoBannerAdSize(for: adFormat, parameters: parameters))
                }
                
                adViewDelegate = .init(adapter: self, delegate: delegate, adFormat: adFormat, parameters: parameters)
                
                adView = await Moloco.shared.createMolocoBanner(params: .init(adUnit: placementId, mediation: "max"), size: size, viewController: viewController)
                
                guard let adView else
                {
                    log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: adFormat)
                    delegate.didFailToLoadAdViewAdWithError(.invalidConfiguration)
                    return
                }
                
                await MainActor.run {
                    adView.delegate = adViewDelegate
                }
                
                await adView.load(bidResponse: parameters.bidResponse)
            }
        }
    }
}

@available(iOS 13.0, *)
extension MolocoAdapter
{
    @MainActor
    private func molocoBannerAdSize(for adFormat: MAAdFormat, parameters: MAAdapterResponseParameters) -> MolocoBannerAdSize
    {
        if isAdaptiveAdViewRequest(adFormat, parameters: parameters)
        {
            let requestedWidth = adaptiveAdViewWidth(from: parameters)
            if let width = Int(exactly: requestedWidth.rounded(.down)), width > 0
            {
                return isInlineAdaptiveAdView(for: parameters)
                    ? .inlineAdaptive(width: width)
                    : .anchoredAdaptive(width: width)
            }

            logWarn("Adaptive \(adFormat.label) ad requested with an unusable width \(requestedWidth), falling back to a fixed size")
        }

        return adFormat == .mrec ? .mrec : .standard
    }

    private func isAdaptiveAdViewRequest(_ adFormat: MAAdFormat, parameters: MAAdapterResponseParameters) -> Bool
    {
        guard (parameters.serverParameters as NSDictionary).al_bool(forKey: "adaptive_banner") else { return false }

        // The AdaptiveAdViewUtils helpers below only exist in AppLovin MAX SDK 13.2.0+.
        guard ALSdk.versionCode >= 13020099 else
        {
            log(customEvent: .unsupportedMaxSDKVersionForAdaptiveAdView)
            return false
        }

        return isAdaptiveAdViewFormat(adFormat, for: parameters)
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

        // Adaptive banners resolve their size from the creative, so report it back to MAX.
        // Moloco SDK delivers didLoad on the main queue after sizing, so the size is final here.
        // Fixed-size banners have no intrinsic size (-1) and are reported without extra info.
        let adSize = adView.intrinsicContentSize
        guard adSize.width > 0, adSize.height > 0 else
        {
            delegate?.didLoadAd(forAdView: adView)
            return
        }

        logInlineAdaptiveMaximumHeightMismatchIfNeeded(adSize)
        delegate?.didLoadAd(forAdView: adView, withExtraInfo: ["ad_width": adSize.width, "ad_height": adSize.height])
    }

    // Moloco SDK has no maximum-height input, so the creative decides the height. Surface it
    // when that exceeds the publisher's inline_adaptive_banner_max_height (device height when
    // unset). Anchored height is not checked: MAAdFormat.adaptiveSize(forWidth:) resolves through
    // the Google adapter and falls back to the fixed banner size without it.
    // Must run on the main queue: reads UIScreen.
    private func logInlineAdaptiveMaximumHeightMismatchIfNeeded(_ adSize: CGSize)
    {
        guard ALSdk.versionCode >= 13020099, adapter.isInlineAdaptiveAdView(for: parameters) else { return }

        let customMaximumHeight = adapter.inlineAdaptiveAdViewMaximumHeight(from: parameters)
        let maximumHeight = customMaximumHeight > 0 ? customMaximumHeight : UIScreen.main.bounds.height
        guard adSize.height > maximumHeight else { return }

        logWarn("[\(adIdentifier)] Inline adaptive \(adFormat.label) ad height \(Int(adSize.height.rounded())) exceeds the maximum height \(Int(maximumHeight.rounded()))")
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
        let adapterError = MAAdapterError.init(adapterError: MAAdapterError.adDisplayFailedError,
                                               mediatedNetworkErrorCode: error?.code ?? MAAdapterError.unspecified.code.rawValue,
                                               mediatedNetworkErrorMessage: error?.localizedDescription ?? MAAdapterError.unspecified.message)
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
        let adapterError = MAAdapterError.init(adapterError: MAAdapterError.adDisplayFailedError,
                                               mediatedNetworkErrorCode: error?.code ?? MAAdapterError.unspecified.code.rawValue,
                                               mediatedNetworkErrorMessage: error?.localizedDescription ?? MAAdapterError.unspecified.message)
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
