//
//  MyTargetAdapter+Rewarded.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 8/17/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

import AppLovinSDK
import MyTargetSDK

extension MyTargetAdapter: MARewardedAdapter
{
    public func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: .rewarded)
        
        guard let slotId = UInt(placementId) else
        {
            log(adEvent: .loadFailed(error: .invalidConfiguration), id: placementId, adFormat: .rewarded)
            delegate.didFailToLoadRewardedAdWithError(.invalidConfiguration)
            return
        }
        
        rewardedDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        rewardedAd = .init(slotId: slotId)
        rewardedAd?.delegate = rewardedDelegate
        rewardedAd?.customParams.setCustomParam(Self.mediationParameter.value, forKey: Self.mediationParameter.key)
        
        updatePrivacyStates(for: parameters)
        
        if parameters.isBidding
        {
            rewardedAd?.load(fromBid: parameters.bidResponse)
        }
        else
        {
            rewardedAd?.load()
        }
    }
    
    public func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
        configureReward(for: parameters)
        rewardedAd?.show(with: presentingViewController(for: parameters))
    }
}

final class MyTargetRewardedAdapterDelegate: RewardedAdapterDelegate<MyTargetAdapter>, MTRGRewardedAdDelegate
{
    func onLoad(with rewardedAd: MTRGRewardedAd)
    {
        log(adEvent: .loaded)
        delegate?.didLoadRewardedAd()
    }
    
    func onLoadFailed(error: Error, rewardedAd: MTRGRewardedAd)
    {
        let adapterError = error.myTargetAdapterError
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadRewardedAdWithError(adapterError)
    }
    
    func onDisplay(with rewardedAd: MTRGRewardedAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayRewardedAd()
    }
    
    func onClick(with rewardedAd: MTRGRewardedAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickRewardedAd()
    }
    
    func onReward(_ reward: MTRGReward, rewardedAd: MTRGRewardedAd)
    {
        log(adEvent: .grantedReward)
        setGrantedReward()
    }
    
    func onClose(with rewardedAd: MTRGRewardedAd)
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
    
    func onLeaveApplication(with rewardedAd: MTRGRewardedAd)
    {
        log(customEvent: .userLeftApplication)
    }
}
