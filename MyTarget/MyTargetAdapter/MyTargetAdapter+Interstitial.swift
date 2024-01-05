//
//  MyTargetAdapter+Interstital.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 8/17/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

import AppLovinSDK
import MyTargetSDK

extension MyTargetAdapter: MAInterstitialAdapter
{
    public func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: .interstitial)
        
        guard let slotId = UInt(placementId) else
        {
            log(adEvent: .loadFailed(error: .invalidConfiguration), id: placementId, adFormat: .interstitial)
            delegate.didFailToLoadInterstitialAdWithError(.invalidConfiguration)
            return
        }
        
        interstitialDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        interstitialAd = .init(slotId: slotId)
        interstitialAd?.delegate = interstitialDelegate
        interstitialAd?.customParams.setCustomParam(Self.mediationParameter.value, forKey: Self.mediationParameter.key)
        
        updatePrivacyStates(for: parameters)
        
        if parameters.isBidding
        {
            interstitialAd?.load(fromBid: parameters.bidResponse)
        }
        else
        {
            interstitialAd?.load()
        }
    }
    
    public func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
        interstitialAd?.show(with: presentingViewController(for: parameters))
    }
}

final class MyTargetInterstitialAdapterDelegate: InterstitialAdapterDelegate<MyTargetAdapter>, MTRGInterstitialAdDelegate
{
    func onLoad(with interstitialAd: MTRGInterstitialAd)
    {
        log(adEvent: .loaded)
        delegate?.didLoadInterstitialAd()
    }
    
    func onLoadFailed(error: Error, interstitialAd: MTRGInterstitialAd)
    {
        let adapterError = error.myTargetAdapterError
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadInterstitialAdWithError(adapterError)
    }
    
    func onDisplay(with interstitialAd: MTRGInterstitialAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayInterstitialAd()
    }
    
    func onClick(with interstitialAd: MTRGInterstitialAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickInterstitialAd()
    }
    
    func onVideoComplete(with interstitialAd: MTRGInterstitialAd)
    {
        log(adEvent: .videoCompleted)
    }
    
    func onClose(with interstitialAd: MTRGInterstitialAd)
    {
        log(adEvent: .hidden)
        delegate?.didHideInterstitialAd()
    }
    
    func onLeaveApplication(with interstitialAd: MTRGInterstitialAd)
    {
        log(customEvent: .userLeftApplication)
    }
}
