//
//  MyTargetAdapter+Native.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 8/17/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

import AppLovinSDK
import MyTargetSDK

extension MyTargetAdapter: MANativeAdAdapter
{
    public func loadNativeAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MANativeAdAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: .native)
        
        guard let slotId = UInt(placementId) else
        {
            log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: .native)
            delegate.didFailToLoadNativeAdWithError(.invalidConfiguration)
            return
        }
        
        nativeAdDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        nativeAd = .init(slotId: slotId)
        nativeAd?.delegate = nativeAdDelegate
        nativeAd?.mediaDelegate = nativeAdDelegate
        nativeAd?.customParams.setCustomParam(Self.mediationParameter.value, forKey: Self.mediationParameter.key)
        
        let adChoicesPlacement = (parameters.serverParameters["ad_choices_placement"] as? UInt) ?? MTRGAdChoicesPlacementTopRight.rawValue
        nativeAd?.adChoicesPlacement = .init(rawValue: adChoicesPlacement)
        
        let cachePolicy = (parameters.serverParameters["cache_policy"] as? UInt32) ?? MTRGCachePolicyAll.rawValue
        nativeAd?.cachePolicy = .init(rawValue: cachePolicy)
        
        updatePrivacyStates(for: parameters)
        
        // NOTE: Only bidding is officially supported by MAX, but placements support is needed for test mode
        if parameters.isBidding
        {
            nativeAd?.load(fromBid: parameters.bidResponse)
        }
        else
        {
            nativeAd?.load()
        }
    }
}

final class MyTargetNativeAdAdapterDelegate: NativeAdAdapterDelegate<MyTargetAdapter>, MTRGNativeAdDelegate, MTRGNativeAdMediaDelegate
{
    func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd)
    {
        log(adEvent: .loaded)
        
        let banner = nativeAd.banner
        
        // Ensure title was provided for template ad
        if templateName != nil && (banner?.title ?? "").isEmpty
        {
            log(adEvent: .missingRequiredAssets)
            delegate?.didFailToLoadNativeAdWithError(.missingRequiredNativeAdAssets)
            
            return
        }
        
        let maxNativeAd = MyTargetNativeAd(adapter: adapter) { builder in
            builder.title = promoBanner.title
            builder.advertiser = promoBanner.advertisingLabel
            builder.body = promoBanner.descriptionText
            builder.callToAction = promoBanner.ctaText
            builder.icon = image(for: promoBanner.icon)
            builder.mainImage = image(for: promoBanner.image)
            
            let mediaView = MTRGNativeViewsFactory.createMediaAdView()
            builder.mediaView = mediaView
            builder.mediaContentAspectRatio = mediaView.aspectRatio
        }
        
        delegate?.didLoadAd(for: maxNativeAd, withExtraInfo: nil)
    }
    
    func onLoadFailed(error: Error, nativeAd: MTRGNativeAd)
    {
        let adapterError = error.myTargetAdapterError
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadNativeAdWithError(adapterError)
    }
    
    func onAdShow(with nativeAd: MTRGNativeAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayNativeAd(withExtraInfo: nil)
    }
    
    func onAdClick(with nativeAd: MTRGNativeAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickNativeAd()
    }
    
    func onShowModal(with nativeAd: MTRGNativeAd)
    {
        logDebug("[\(adIdentifier)] Native ad modal shown")
    }
    
    func onDismissModal(with nativeAd: MTRGNativeAd)
    {
        logDebug("[\(adIdentifier)] Native ad modal dismissed")
    }
    
    func onLeaveApplication(with nativeAd: MTRGNativeAd)
    {
        log(customEvent: .userLeftApplication)
    }
    
    func onVideoPlay(with nativeAd: MTRGNativeAd)
    {
        log(adEvent: .videoStarted)
    }
    
    func onVideoPause(with nativeAd: MTRGNativeAd)
    {
        log(adEvent: .videoPaused)
    }
    
    func onVideoComplete(with nativeAd: MTRGNativeAd)
    {
        log(adEvent: .videoCompleted)
    }
    
    private func image(for imageData: MTRGImageData?) -> MANativeAdImage?
    {
        guard let imageData else { return nil }
        
        guard let image = imageData.image else
        {
            return MANativeAdImage(url: URL(string: imageData.url)!) // URL may require fetching
        }
        
        return MANativeAdImage(image: image) // Cached
    }
    
    func onIconLoad(with nativeAd: MTRGNativeAd)
    {
        logDebug("[\(adIdentifier)] Native ad icon loaded")
    }
    
    func onImageLoad(with nativeAd: MTRGNativeAd)
    {
        logDebug("[\(adIdentifier)] Native ad image icon loaded")
    }
    
    func onAdChoicesIconLoad(with nativeAd: MTRGNativeAd)
    {
        logDebug("[\(adIdentifier)] Native ad choices icon loaded")
    }
}

final class MyTargetNativeAd: MANativeAd
{
    private unowned let adapter: MyTargetAdapter
    
    init(adapter: MyTargetAdapter, builder: (MANativeAdBuilder) -> ())
    {
        self.adapter = adapter
        super.init(format: .native, builderBlock: builder)
    }
    
    override func prepare(forInteractionClickableViews clickableViews: [UIView], withContainer container: UIView) -> Bool
    {
        guard let nativeAd = adapter.nativeAd else
        {
            adapter.log(adEvent: .registerAdViewsFailed(description: "Native ad is nil"), adFormat: .native)
            return false
        }
        
        adapter.log(adEvent: .preparingViewsForInteraction(views: clickableViews, container: container), adFormat: .native)
        
        nativeAd.register(container, with: ALUtils.topViewControllerFromKeyWindow(), withClickableViews: clickableViews)
        
        return true
    }
}
