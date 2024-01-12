//
//  HyprMXAdapter+Interstitial.swift
//  HyprMXAdapter
//
//  Created by Chris Cong on 10/5/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import HyprMX

extension HyprMXAdapter: MAInterstitialAdapter
{
    public func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(isBidding: parameters.isBidding), id: placementId, adFormat: .interstitial)
        
        updatePrivacyStates(for: parameters)
        
        guard let placement = HyprMX.getPlacement(placementId) else
        {
            let adapterError = MAAdapterError(adapterError: .invalidConfiguration,
                                              mediatedNetworkErrorCode: Int(PLACEMENT_DOES_NOT_EXIST.rawValue),
                                              mediatedNetworkErrorMessage: "Failed to retrieve HyprMX placement: \(placementId)")
            log(adEvent: .loadFailed(error: adapterError), id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
            delegate.didFailToLoadInterstitialAdWithError(adapterError)
            return
        }
        
        interstitialAd = placement
        interstitialDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        loadFullscreenAd(for: placement, parameters: parameters, delegate: interstitialDelegate)
    }
    
    public func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
        
        guard let interstitialAd, interstitialAd.isAdAvailable() else
        {
            log(adEvent: .notReady, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
            delegate.didFailToDisplayInterstitialAdWithError(.adNotReady)
            return
        }
        
        interstitialAd.showAd(from: presentingViewController(for: parameters))
    }
}

final class HyprMXInterstitialAdapterDelegate: InterstitialAdapterDelegate<HyprMXAdapter>, HyprMXPlacementDelegate
{
    func adAvailable(for placement: HyprMXPlacement)
    {
        log(adEvent: .loaded, id: placement.placementName)
        delegate?.didLoadInterstitialAd()
    }
    
    func adNotAvailable(for placement: HyprMXPlacement)
    {
        let adapterError = MAAdapterError.noFill
        log(adEvent: .loadFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToLoadInterstitialAdWithError(adapterError)
    }
    
    func adExpired(for placement: HyprMXPlacement)
    {
        log(adEvent: .expired, id: placement.placementName)
    }
    
    func adWillStart(for placement: HyprMXPlacement)
    {
        log(adEvent: .displayed, id: placement.placementName)
        delegate?.didDisplayInterstitialAd()
    }
    
    func adDidClose(for placement: HyprMXPlacement, didFinishAd finished: Bool)
    {
        log(adEvent: .hidden, id: placement.placementName, appending: "didFinishAd \(finished)")
        delegate?.didHideInterstitialAd()
    }
    
    func adDisplayError(_ error: Error, placement: HyprMXPlacement)
    {
        let adapterError = error.hyprMXAdapterError
        log(adEvent: .displayFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToDisplayInterstitialAdWithError(adapterError)
    }
}
