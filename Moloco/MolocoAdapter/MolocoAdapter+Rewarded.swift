//
//  MolocoAdapter+Rewarded.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/7/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

extension MolocoAdapter: MARewardedAdapter
{
    func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: .rewarded)
        
        updatePrivacyStates(for: parameters)
        
        Task {
            rewardedDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
            rewardedAd = await Moloco.shared.createRewarded(for: placementId, delegate: rewardedDelegate)
            guard let rewardedAd else
            {
                log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: .rewarded)
                delegate.didFailToLoadRewardedAdWithError(.invalidConfiguration)
                return
            }
            
            await rewardedAd.load(bidResponse: parameters.bidResponse)
        }
    }
    
    func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .showing, id: placementId, adFormat: .rewarded)

        guard let rewardedAd, rewardedAd.isReady else
        {
            log(adEvent: .notReady, id: placementId, adFormat: .rewarded)
            delegate.didFailToDisplayRewardedAdWithError(.adNotReady)
            return
        }
        
        configureReward(for: parameters)
        
        Task {
            await rewardedAd.show(from: presentingViewController(for: parameters))
        }
    }
}

final class MolocoRewardedAdapterDelegate: RewardedAdapterDelegate<MolocoAdapter>, MolocoRewardedDelegate
{
    func didLoad(ad: MolocoAd)
    {
        log(adEvent: .loaded)
        delegate?.didLoadRewardedAd()
    }
    
    func failToLoad(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadRewardedAdWithError(adapterError)
    }
    
    func didShow(ad: MolocoAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayRewardedAd()
    }
    
    func failToShow(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .displayFailed(error: adapterError))
        delegate?.didFailToDisplayRewardedAdWithError(adapterError)
    }
    
    func rewardedVideoStarted(ad: MolocoAd)
    {
        log(adEvent: .videoStarted)
    }
    
    func rewardedVideoCompleted(ad: MolocoAd)
    {
        log(adEvent: .videoCompleted)
    }
    
    func userRewarded(ad: MolocoAd)
    {
        log(adEvent: .grantedReward)
        setGrantedReward()
    }
    
    func didClick(on ad: MolocoAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickRewardedAd()
    }
    
    func didHide(ad: MolocoAd)
    {
        if hasGrantedReward || adapter.shouldAlwaysRewardUser
        {
            let reward = adapter.reward
            log(adEvent: .userRewarded(reward: reward))
            delegate?.didRewardUser(with: reward)
        }
        
        log(adEvent: .hidden)
        delegate?.didHideRewardedAd()
    }
}
