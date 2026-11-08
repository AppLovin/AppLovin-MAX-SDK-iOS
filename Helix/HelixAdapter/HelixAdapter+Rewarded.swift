//
//  HelixAdapter+Rewarded.swift
//  HelixAdapter
//
//  Created by Nana Amoah on 9/25/26.
//  Copyright © 2026 AppLovin. All rights reserved.
//

import AppLovinSDK
import VoodooAdn

@available(iOS 14.0, *)
extension HelixAdapter: MARewardedAdapter
{
    func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "14.0", maxVersion: nil) else
        {
            logInfo("Current iOS version is: \(UIDevice.current.systemVersion), but Helix requires minimum iOS 14.0")
            delegate.didFailToLoadRewardedAdWithError(.unspecified)
            return
        }
        
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: .rewarded)
        
        updatePrivacyStates(for: parameters)
        
        rewardedAd = nil
        rewardedDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        AdnSdk.loadFullScreenAd(.init(placement: .rewarded,
                                      adMarkup: parameters.bidResponse,
                                      configuration: nil)) { [weak self] result in
            self?.rewardedDelegate?.handleLoadResult(result)
        }
    }
    
    func showRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .showing, id: placementId, adFormat: .rewarded)
        
        guard let rewardedAd, let rewardedDelegate else
        {
            let adapterError = MAAdapterError(adapterError: .adDisplayFailedError,
                                              mediatedNetworkErrorCode: MAAdapterError.adNotReady.code.rawValue,
                                              mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message)
            log(adEvent: .notReady, id: placementId, adFormat: .rewarded)
            delegate.didFailToDisplayRewardedAdWithError(adapterError)
            return
        }
        
        configureReward(for: parameters)
        
        rewardedAd.show(with: .init(viewController: presentingViewController(for: parameters))) { [weak rewardedDelegate] event in
            rewardedDelegate?.handleShowEvent(event)
        }
    }
}

@available(iOS 14.0, *)
final class HelixRewardedAdapterDelegate: RewardedAdapterDelegate<HelixAdapter>
{
    func handleLoadResult(_ result: Result<AdnSdk.AdUnit, Error>)
    {
        switch result
        {
        case .success(let ad):
            adapter.rewardedAd = ad
            log(adEvent: .loaded)
            delegate?.didLoadRewardedAd()
        case .failure(let error):
            let adapterError = error.helixLoadAdapterError
            log(adEvent: .loadFailed(error: adapterError))
            delegate?.didFailToLoadRewardedAdWithError(adapterError)
        }
    }
    
    func handleShowEvent(_ event: AdnSdk.AdFullscreenShowState)
    {
        switch event
        {
        case .click:
            log(adEvent: .clicked)
            delegate?.didClickRewardedAd()
        case .impression:
            log(adEvent: .displayed)
            delegate?.didDisplayRewardedAd()
        case .dismissed:
            if hasGrantedReward || adapter.shouldAlwaysRewardUser
            {
                let reward = adapter.reward
                log(adEvent: .userRewarded(reward: reward))
                delegate?.didRewardUser(with: reward)
            }
            
            log(adEvent: .hidden)
            delegate?.didHideRewardedAd()
        case .rewarded:
            log(adEvent: .grantedReward)
            setGrantedReward()
        case .failure(let error):
            let adapterError = error.helixDisplayAdapterError
            log(adEvent: .displayFailed(error: adapterError))
            delegate?.didFailToDisplayRewardedAdWithError(adapterError)
        case .started:
            log(adEvent: .videoStarted)
        @unknown default:
            break
        }
    }
}
