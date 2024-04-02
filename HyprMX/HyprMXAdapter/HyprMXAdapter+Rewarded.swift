//
//  HyprMXAdapter+Rewarded.swift
//  HyprMXAdapter
//
//  Created by Chris Cong on 10/6/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import HyprMX

extension HyprMXAdapter: MARewardedAdapter
{
    func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: .rewarded)
        
        updatePrivacyStates(for: parameters)
        
        guard let placement = HyprMX.getPlacement(placementId) else
        {
            let adapterError = MAAdapterError(adapterError: .invalidConfiguration,
                                              mediatedNetworkErrorCode: Int(PLACEMENT_DOES_NOT_EXIST.rawValue),
                                              mediatedNetworkErrorMessage: "Failed to retrieve HyprMX placement: \(placementId)")
            log(adEvent: .loadFailed(error: adapterError), id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
            delegate.didFailToLoadRewardedAdWithError(adapterError)
            return
        }
        
        rewardedAd = placement
        rewardedDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        loadFullscreenAd(for: placement, parameters: parameters, delegate: rewardedDelegate)
    }
    
    func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
        
        guard let rewardedAd, rewardedAd.isAdAvailable() else
        {
            log(adEvent: .notReady, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
            delegate.didFailToDisplayRewardedAdWithError(.adNotReady)
            return
        }
        
        rewardedAd.showAd(from: presentingViewController(for: parameters))
    }
}

final class HyprMXRewardedAdapterDelegate: RewardedAdapterDelegate<HyprMXAdapter>, HyprMXPlacementDelegate
{
    func adAvailable(for placement: HyprMXPlacement)
    {
        log(adEvent: .loaded, id: placement.placementName)
        delegate?.didLoadRewardedAd()
    }
    
    func adNotAvailable(for placement: HyprMXPlacement)
    {
        let adapterError = MAAdapterError.noFill
        log(adEvent: .loadFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToLoadRewardedAdWithError(adapterError)
    }
    
    func adExpired(for placement: HyprMXPlacement)
    {
        log(adEvent: .expired, id: placement.placementName)
    }
    
    func adWillStart(for placement: HyprMXPlacement)
    {
        log(adEvent: .displayed, id: placement.placementName)
        delegate?.didDisplayRewardedAd()
    }
    
    func adDidClose(for placement: HyprMXPlacement, didFinishAd finished: Bool)
    {
        if hasGrantedReward || adapter.shouldAlwaysRewardUser
        {
            let reward = adapter.reward
            log(adEvent: .userRewarded(reward: reward), id: placement.placementName)
            delegate?.didRewardUser(with: reward)
        }
        
        log(adEvent: .hidden, id: placement.placementName, appending: "didFinishAd: \(finished)")
        delegate?.didHideRewardedAd()
    }
    
    func adDisplayError(_ error: Error, placement: HyprMXPlacement)
    {
        let adapterError = error.hyprMXAdapterError
        log(adEvent: .displayFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToDisplayRewardedAdWithError(adapterError)
    }
    
    func adDidReward(for placement: HyprMXPlacement, rewardName: String?, rewardValue: Int)
    {
        log(adEvent: .grantedReward, id: placement.placementName, appending: "Reward: \(rewardValue) \(rewardName ?? "")")
        setGrantedReward()
    }
}
