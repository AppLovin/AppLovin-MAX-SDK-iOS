//
//  HelixAdapter+Interstitial.swift
//  HelixAdapter
//
//  Created by Nana Amoah on 9/25/26.
//  Copyright © 2026 AppLovin. All rights reserved.
//

import AppLovinSDK
import VoodooAdn

@available(iOS 14.0, *)
extension HelixAdapter: MAInterstitialAdapter
{
    func loadInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "14.0", maxVersion: nil) else
        {
            logInfo("Current iOS version is: \(UIDevice.current.systemVersion), but Helix requires minimum iOS 14.0")
            delegate.didFailToLoadInterstitialAdWithError(.unspecified)
            return
        }
        
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .loading(), id: placementId, adFormat: .interstitial)
        
        updatePrivacyStates(for: parameters)
        
        interstitialAd = nil
        interstitialDelegate = .init(adapter: self, delegate: delegate, parameters: parameters)
        
        AdnSdk.loadFullScreenAd(.init(placement: .interstitial,
                                      adMarkup: parameters.bidResponse,
                                      configuration: nil)) { [weak self] result in
            self?.interstitialDelegate?.handleLoadResult(result)
        }
    }
    
    func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate)
    {
        let placementId = parameters.thirdPartyAdPlacementIdentifier
        
        log(adEvent: .showing, id: placementId, adFormat: .interstitial)
        
        guard let interstitialAd, let interstitialDelegate else
        {
            let adapterError = MAAdapterError(adapterError: .adDisplayFailedError,
                                              mediatedNetworkErrorCode: MAAdapterError.adNotReady.code.rawValue,
                                              mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message)
            log(adEvent: .notReady, id: placementId, adFormat: .interstitial)
            delegate.didFailToDisplayInterstitialAdWithError(adapterError)
            return
        }
        
        interstitialAd.show(with: .init(viewController: presentingViewController(for: parameters))) { [weak interstitialDelegate] event in
            interstitialDelegate?.handleShowEvent(event)
        }
    }
}

@available(iOS 14.0, *)
final class HelixInterstitialAdapterDelegate: InterstitialAdapterDelegate<HelixAdapter>
{
    func handleLoadResult(_ result: Result<AdnSdk.AdUnit, Error>)
    {
        switch result
        {
        case .success(let ad):
            adapter.interstitialAd = ad
            log(adEvent: .loaded)
            delegate?.didLoadInterstitialAd()
        case .failure(let error):
            let adapterError = error.helixLoadAdapterError
            log(adEvent: .loadFailed(error: adapterError))
            delegate?.didFailToLoadInterstitialAdWithError(adapterError)
        }
    }
    
    func handleShowEvent(_ event: AdnSdk.AdFullscreenShowState)
    {
        switch event
        {
        case .click:
            log(adEvent: .clicked)
            delegate?.didClickInterstitialAd()
        case .impression:
            log(adEvent: .displayed)
            delegate?.didDisplayInterstitialAd()
        case .dismissed:
            log(adEvent: .hidden)
            delegate?.didHideInterstitialAd()
        case .failure(let error):
            let adapterError = error.helixDisplayAdapterError
            log(adEvent: .displayFailed(error: adapterError))
            delegate?.didFailToDisplayInterstitialAdWithError(adapterError)
        case .rewarded, .started:
            break
        @unknown default:
            break
        }
    }
}
