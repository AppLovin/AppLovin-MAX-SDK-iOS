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
                    let viewController = presentingViewController(for: parameters)
                    let size = molocoBannerAdSize(for: adFormat, parameters: parameters, presentingViewController: viewController)
                    return (viewController, size)
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
    func molocoBannerAdSize(for adFormat: MAAdFormat,
                            parameters: MAAdapterResponseParameters,
                            presentingViewController: UIViewController) -> MolocoBannerAdSize
    {
        let isAdaptiveBanner = boolValue(adaptiveParameter("adaptive_banner", from: parameters))
        if isAdaptiveBanner, isAdaptiveAdViewFormat(adFormat, parameters: parameters)
        {
            let width = adaptiveBannerWidth(from: parameters, presentingViewController: presentingViewController)
            return isInlineAdaptiveBanner(parameters)
                ? .inlineAdaptive(width: Int(width))
                : .anchoredAdaptive(width: Int(width))
        }

        switch adFormat
        {
        case .banner, .leader:
            return .standard
        case .mrec:
            return .mrec
        default:
            return .standard
        }
    }

    // Adaptive banners must be inline for MRECs.
    private func isAdaptiveAdViewFormat(_ adFormat: MAAdFormat, parameters: MAAdapterResponseParameters) -> Bool
    {
        if adFormat == MAAdFormat.mrec
        {
            return isInlineAdaptiveBanner(parameters)
        }
        return adFormat == MAAdFormat.banner || adFormat == MAAdFormat.leader
    }

    private func isInlineAdaptiveBanner(_ parameters: MAAdapterResponseParameters) -> Bool
    {
        guard let type = adaptiveParameter("adaptive_banner_type", from: parameters) as? String else { return false }
        return type.caseInsensitiveCompare("inline") == .orderedSame
    }

    @MainActor
    private func adaptiveBannerWidth(from parameters: MAAdapterResponseParameters,
                                     presentingViewController: UIViewController) -> CGFloat
    {
        if let customWidth = adaptiveParameter("adaptive_banner_width", from: parameters) as? NSNumber
        {
            return CGFloat(customWidth.doubleValue)
        }
        if let window = presentingViewController.view.window
        {
            return window.frame.inset(by: window.safeAreaInsets).width
        }
        return UIScreen.main.bounds.width
    }

    // Adaptive params arrive via serverParameters (server-enabled networks) or
    // localExtraParameters (client MAAdViewConfiguration). Read both.
    private func adaptiveParameter(_ key: String, from parameters: MAAdapterResponseParameters) -> Any?
    {
        parameters.localExtraParameters[key] ?? parameters.serverParameters[key]
    }

    private func boolValue(_ value: Any?) -> Bool
    {
        if let value = value as? Bool { return value }
        if let value = value as? NSNumber { return value.boolValue }
        if let value = value as? String { return (value as NSString).boolValue }
        return false
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
