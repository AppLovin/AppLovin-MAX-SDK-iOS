//
//  MolocoAdapter+Interstitial.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/7/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@available(iOS 13.0, *)
extension MolocoAdapter: MAInterstitialAdapter
{
    func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard #available(iOS 13.0, *) else
        {
            log(customEvent: .unsupportedMinimumOS)
            delegate.didFailToLoadInterstitialAdWithError(.unspecified)
            return
        }
        
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: .interstitial)
        
        updatePrivacyStates(for: parameters)
        
        Task {
            interstitialDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
            interstitialAd = await Moloco.shared.createInterstitial(for: placementId, delegate: interstitialDelegate)
            guard let interstitialAd else
            {
                log(adEvent: .loadFailed(error: .invalidConfiguration), adFormat: .interstitial)
                delegate.didFailToLoadInterstitialAdWithError(.invalidConfiguration)
                return
            }
            
            await interstitialAd.load(bidResponse: parameters.bidResponse)
        }
    }
    
    func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .showing, id: placementId, adFormat: .interstitial)
        
        guard let interstitialAd, interstitialAd.isReady else
        {
            log(adEvent: .notReady, id: placementId, adFormat: .interstitial)
            delegate.didFailToDisplayInterstitialAdWithError(.adNotReady)
            return
        }
        
        Task {
            await interstitialAd.show(from: presentingViewController(for: parameters))
        }
    }
}

@available(iOS 13.0, *)
final class MolocoInterstitialAdapterDelegate: InterstitialAdapterDelegate<MolocoAdapter>, MolocoInterstitialDelegate
{
    func didLoad(ad: MolocoAd)
    {
        log(adEvent: .loaded)
        delegate?.didLoadInterstitialAd()
    }
    
    func failToLoad(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .loadFailed(error: adapterError))
        delegate?.didFailToLoadInterstitialAdWithError(adapterError)
    }
    
    func didShow(ad: MolocoAd)
    {
        log(adEvent: .displayed)
        delegate?.didDisplayInterstitialAd()
    }
    
    func failToShow(ad: MolocoAd, with error: Error?)
    {
        let adapterError = error?.molocoAdapterError ?? .unspecified
        log(adEvent: .displayFailed(error: adapterError))
        delegate?.didFailToDisplayInterstitialAdWithError(adapterError)
    }
    
    func didClick(on ad: MolocoAd)
    {
        log(adEvent: .clicked)
        delegate?.didClickInterstitialAd()
    }
    
    func didHide(ad: MolocoAd)
    {
        log(adEvent: .hidden)
        delegate?.didHideInterstitialAd()
    }
}
