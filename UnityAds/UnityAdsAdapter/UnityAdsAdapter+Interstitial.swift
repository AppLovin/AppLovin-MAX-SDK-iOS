//
//  UnityAdsAdapter+Interstitial.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import UnityAds

extension UnityAdsAdapter: MAInterstitialAdapter
{
    func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        log(adEvent: .loading(isBidding: parameters.isBidding), adFormat: .interstitial)
        
        updatePrivacyConsent(for: parameters)
        
        interstitialDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        // Every ad needs a random ID associated with each load and show
        biddingAdIdentifier = NSUUID().uuidString
        
        UnityAds.load(placementId,
                      options: parameters.unityAdLoadOptions(with: biddingAdIdentifier),
                      loadDelegate: interstitialDelegate)
    }
    
    func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        log(adEvent: .showing, adFormat: .interstitial)
        
        // Paranoia check
        interstitialDelegate = interstitialDelegate ?? .init(adapter: self, delegate: delegate, parameters: parameters)

        UnityAds.show(presentingViewController(for: parameters),
                      placementId: placementId,
                      options: parameters.unityAdShowOptions(with: biddingAdIdentifier),
                      showDelegate: interstitialDelegate)
    }
}

final class UnityAdsInterstitialAdapterDelegate: InterstitialAdapterDelegate<UnityAdsAdapter>, UnityAdsLoadDelegate, UnityAdsShowDelegate
{
    func unityAdsAdLoaded(_ placementId: String)
    {
        log(adEvent: .loaded)
        delegate?.didLoadInterstitialAd()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String)
    {
        let adapterError = error.unityAdsAdapterError(with: message)
        
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadInterstitialAdWithError(adapterError)
    }
    
    func unityAdsShowStart(_ placementId: String)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayInterstitialAd()
    }
    
    func unityAdsShowClick(_ placementId: String)
    {
        log(adEvent: .clicked)
        delegate?.didClickInterstitialAd()
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState)
    {
        log(adEvent: .hidden)
        delegate?.didHideInterstitialAd()
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String)
    {
        let adapterError = error.unityAdsAdapterError(with: message)
        
        log(adEvent: .displayFailed(error: adapterError))
        delegate?.didFailToDisplayInterstitialAdWithError(adapterError)
    }
}
