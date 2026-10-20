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
        
        let completionHandler: (Bool) -> () = { success in

            guard success else
            {
                self.log(adEvent: .loadFailed(error: .noFill), id: placementId, adFormat: .rewarded)
                delegate.didFailToLoadRewardedAdWithError(.noFill)
                return
            }

            self.log(adEvent: .loaded, id: placementId, adFormat: .rewarded)
            delegate.didLoadRewardedAd()
        }

        if parameters.isBidding
        {
            placement.loadAd(withBidResponse: parameters.bidResponse, completion: completionHandler)
        }
        else
        {
            placement.loadAd(completion: completionHandler)
        }
    }
    
    func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
        
        guard let rewardedAd, rewardedAd.isAdAvailable else
        {
            log(adEvent: .notReady, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
            delegate.didFailToDisplayRewardedAdWithError(.adNotReady)
            return
        }
        
        rewardedAd.showAd(from: presentingViewController(for: parameters), delegate: rewardedDelegate)
    }
}

final class HyprMXRewardedAdapterDelegate: RewardedAdapterDelegate<HyprMXAdapter>, HyprMXPlacementShowDelegate
{
    func adWillStart(placement: HyprMXPlacement)
    {
        log(adEvent: .willShow, id: placement.placementName)
    }
    
    func adImpression(placement: HyprMXPlacement)
    {
        log(adEvent: .displayed, id: placement.placementName)
        delegate?.didDisplayRewardedAd()
    }
    
    func adDisplay(error: NSError, placement: HyprMXPlacement)
    {
        let adapterError = MAAdapterError(adapterError: .adDisplayFailedError,
                                          mediatedNetworkErrorCode: error.code,
                                          mediatedNetworkErrorMessage: error.localizedDescription)
        log(adEvent: .displayFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToDisplayRewardedAdWithError(adapterError)
    }
    
    func adDidReward(placement: HyprMXPlacement, rewardName: String?, rewardValue: Int)
    {
        log(adEvent: .grantedReward, id: placement.placementName, appending: "Reward: \(rewardValue) \(rewardName ?? "")")
        setGrantedReward()
    }
    
    func adDidClose(placement: HyprMXPlacement, finished: Bool)
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
}
