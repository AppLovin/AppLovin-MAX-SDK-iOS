//
//  HyprMXAdapter.swift
//  HyprMXAdapter
//
//  Created by Chris Cong on 9/21/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import HyprMX

@objc(ALHyprMXMediationAdapter)
final class HyprMXAdapter: ALMediationAdapter
{
    private static let initialized = ALAtomicBoolean()
    private static var initializationStatus: MAAdapterInitializationStatus = .adapterNotInitialized

    // MARK: - Instance Properties
    
    // MARK: Ads
    
    var interstitialAd: HyprMXPlacement?
    var interstitialDelegate: HyprMXInterstitialAdapterDelegate?

    var rewardedAd: HyprMXPlacement?
    var rewardedDelegate: HyprMXRewardedAdapterDelegate?

    var adView: HyprMXBannerView?
    var adViewDelegate: HyprMXAdViewAdapterDelegate?

    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "HyprMX" }
    
    override var adapterVersion: String { "6.4.2.0.0" }

    override var sdkVersion: String { HyprMX.versionString() }

    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            completionHandler(Self.initializationStatus, nil)
            return
        }
        
        let distributorId = parameters.serverParameters["distributor_id"] as? String ?? ""

        Self.initializationStatus = .initializing
        
        log(lifecycleEvent: .initializing(parameters: ["distributorId": distributorId]))
        
        let logLevel = parameters.isTesting ? HYPRLogLevelVerbose : HYPRLogLevelError
        HyprMX.setLogLevel(logLevel)
        
        HyprMX.setMediationProvider(HyprMXMediationProviderApplovinMax, mediatorSDKVersion: ALSdk.version(), adapterVersion: adapterVersion)
        
        updatePrivacyStates(for: parameters)
        
        HyprMX.initialize(distributorId) { success, error in

            guard success else
            {
                self.log(lifecycleEvent: .initializeFailure(description: error?.localizedDescription))
                
                Self.initializationStatus = .initializedFailure
                completionHandler(Self.initializationStatus, error?.localizedDescription)
                
                return
            }

            self.log(lifecycleEvent: .initializeSuccess())
            
            Self.initializationStatus = .initializedSuccess
            completionHandler(Self.initializationStatus, nil)
        }
    }

    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        interstitialAd = nil
        interstitialDelegate = nil

        rewardedAd = nil
        rewardedDelegate = nil

        adView?.placementDelegate = nil
        adView = nil
        adViewDelegate = nil
    }
    
    // MARK: Privacy
    
    func updatePrivacyStates(for parameters: MAAdapterParameters)
    {
        // NOTE: HyprMX requested to always set GDPR regardless of region.
        HyprMX.setConsentStatus(consentStatus(for: parameters))
        
        // NOTE: HyprMX deals with CCPA via their UI
    }
    
    private func consentStatus(for parameters: MAAdapterParameters) -> HyprConsentStatus
    {
        let hasUserConsent = parameters.userConsent?.boolValue ?? false // if set, check if true; otherwise, return false
        let isDoNotSell = parameters.doNotSell?.boolValue ?? false
        
        if hasUserConsent, !isDoNotSell
        {
            return CONSENT_GIVEN
        }
        else if isDoNotSell || !hasUserConsent
        {
            return CONSENT_DECLINED
        }
        else
        {
            return CONSENT_STATUS_UNKNOWN
        }
    }
}

// MARK: - MASignalProvider

extension HyprMXAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        log(signalEvent: .collecting)
        
        updatePrivacyStates(for: parameters)
        
        let signal = HyprMX.sessionToken()
        delegate.didCollectSignal(signal)
    }
}
