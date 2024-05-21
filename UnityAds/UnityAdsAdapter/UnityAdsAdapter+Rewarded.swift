//
//  UnityAdsAdapter+Rewarded.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import UnityAds

extension UnityAdsAdapter: MARewardedAdapter
{
    func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        log(adEvent: .loading(isBidding: parameters.isBidding), adFormat: .rewarded)
        
        updatePrivacyConsent(for: parameters)
        
        rewardedDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        // Every ad needs a random ID associated with each load and show
        biddingAdIdentifier = NSUUID().uuidString
        
        UnityAds.load(placementId,
                      options: parameters.unityAdLoadOptions(with: biddingAdIdentifier),
                      loadDelegate: rewardedDelegate)
    }
    
    func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        log(adEvent: .showing, adFormat: .rewarded)
        
        // Paranoia check
        rewardedDelegate = rewardedDelegate ?? .init(adapter: self, delegate: delegate, parameters: parameters)
        
        configureReward(for: parameters)
        
        UnityAds.show(presentingViewController(for: parameters),
                      placementId: placementId,
                      options: parameters.unityAdShowOptions(with: biddingAdIdentifier),
                      showDelegate: rewardedDelegate)
    }
}

final class UnityAdsRewardedAdapterDelegate: RewardedAdapterDelegate<UnityAdsAdapter>, UnityAdsLoadDelegate, UnityAdsShowDelegate
{
    func unityAdsAdLoaded(_ placementId: String)
    {
        log(adEvent: .loaded)
        delegate?.didLoadRewardedAd()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String)
    {
        let adapterError = error.unityAdsAdapterError(with: message)
        
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadRewardedAdWithError(adapterError)
    }
    
    func unityAdsShowStart(_ placementId: String)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayRewardedAd()
    }
    
    func unityAdsShowClick(_ placementId: String)
    {
        log(adEvent: .clicked)
        delegate?.didClickRewardedAd()
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState)
    {
        if state == .showCompletionStateCompleted || adapter.shouldAlwaysRewardUser
        {
            let reward = adapter.reward
            log(adEvent: .userRewarded(reward: reward))
            delegate?.didRewardUser(with: reward)
        }
        
        log(adEvent: .hidden)
        delegate?.didHideRewardedAd()
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String)
    {
        let adapterError = error.unityAdsAdapterError(with: message)
        
        log(adEvent: .displayFailed(error: adapterError))
        delegate?.didFailToDisplayRewardedAdWithError(adapterError)
    }
}
