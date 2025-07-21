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

        let completionHandler: (Bool) -> () = { success in

            guard success else
            {
                self.log(adEvent: .loadFailed(error: .noFill), id: placementId, adFormat: .interstitial)
                delegate.didFailToLoadInterstitialAdWithError(.noFill)
                return
            }

            self.log(adEvent: .loaded, id: placementId, adFormat: .interstitial)
            delegate.didLoadInterstitialAd()
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
    
    public func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
        
        guard let interstitialAd, interstitialAd.isAdAvailable else
        {
            log(adEvent: .notReady, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
            delegate.didFailToDisplayInterstitialAdWithError(.adNotReady)
            return
        }
        
        interstitialAd.showAd(from: presentingViewController(for: parameters), delegate: interstitialDelegate)
    }
}

final class HyprMXInterstitialAdapterDelegate: InterstitialAdapterDelegate<HyprMXAdapter>, HyprMXPlacementShowDelegate
{
    func adWillStart(placement: HyprMXPlacement)
    {
        log(adEvent: .willShow, id: placement.placementName)
    }
    
    func adImpression(placement: HyprMXPlacement)
    {
        log(adEvent: .displayed, id: placement.placementName)
        delegate?.didDisplayInterstitialAd()
    }
    
    func adDisplay(error: NSError, placement: HyprMXPlacement)
    {
        let adapterError = MAAdapterError(adapterError: .adDisplayFailedError,
                                          mediatedNetworkErrorCode: error.code,
                                          mediatedNetworkErrorMessage: error.localizedDescription)
        log(adEvent: .displayFailed(error: adapterError), id: placement.placementName)
        delegate?.didFailToDisplayInterstitialAdWithError(adapterError)
    }
    
    func adDidClose(placement: HyprMXPlacement, finished: Bool)
    {
        log(adEvent: .hidden, id: placement.placementName, appending: "didFinishAd \(finished)")
        delegate?.didHideInterstitialAd()
    }
}
