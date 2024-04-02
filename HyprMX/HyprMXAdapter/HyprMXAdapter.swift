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
    private static let randomUserIdKey = "com.applovin.sdk.mediation.random_hyprmx_user_id"
    
    // MARK: - Instance Properties
    
    var initializationCompletionHandler: MAAdapterInitializationCompletionHandler?
    
    // MARK: Ads
    
    var interstitialAd: HyprMXPlacement?
    var interstitialDelegate: HyprMXInterstitialAdapterDelegate?

    var rewardedAd: HyprMXPlacement?
    var rewardedDelegate: HyprMXRewardedAdapterDelegate?

    var adView: HyprMXBannerView?
    var adViewDelegate: HyprMXAdViewAdapterDelegate?

    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "HyprMX" }
    
    override var adapterVersion: String { "6.3.0.1.1" }

    override var sdkVersion: String { HyprMX.versionString() }

    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        guard HyprMX.initializationStatus() == NOT_INITIALIZED else
        {
            switch HyprMX.initializationStatus()
            {
            case INITIALIZATION_COMPLETE:
                completionHandler(.initializedSuccess, nil)
            case INITIALIZATION_FAILED:
                completionHandler(.initializedFailure, nil)
            case INITIALIZING:
                completionHandler(.initializing, nil)
            case NOT_INITIALIZED:
                completionHandler(.adapterNotInitialized, nil)
            default:
                completionHandler(.initializedUnknown, nil)
            }
            
            return
        }
        
        let distributorId = parameters.serverParameters["distributor_id"] as? String ?? ""
        
        // HyprMX requires userId to initialize -> generate a random one
        var userId = sdk?.userIdentifier ?? ""
        if userId.isEmpty
        {
            userId = UUID().uuidString.lowercased()
            UserDefaults.standard.set(userId, forKey: HyprMXAdapter.randomUserIdKey)
        }
        
        initializationCompletionHandler = completionHandler
        
        log(lifecycleEvent: .initializing(parameters: ["distributorId": distributorId]))
        
        let logLevel = parameters.isTesting ? HYPRLogLevelVerbose : HYPRLogLevelError
        HyprMX.setLogLevel(logLevel)
        
        HyprMX.setMediationProvider(HyprMXMediationProviderApplovinMax, mediatorSDKVersion: ALSdk.version(), adapterVersion: adapterVersion)
        
        // NOTE: HyprMX deals with CCPA via their UI
        HyprMX.initialize(withDistributorId: distributorId,
                          userId: userId,
                          consentStatus: consentStatus(for: parameters),
                          ageRestrictedUser: parameters.ageRestrictedUser?.boolValue ?? false,
                          initializationDelegate: self)
    }

    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        interstitialAd?.placementDelegate = nil
        interstitialAd = nil
        interstitialDelegate = nil

        rewardedAd?.placementDelegate = nil
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
    
    // MARK: Common Fullscreen Functions
    
    public func loadFullscreenAd(for placement: HyprMXPlacement, parameters: MAAdapterResponseParameters, delegate: HyprMXPlacementDelegate?)
    {
        placement.placementDelegate = delegate
        
        if parameters.isBidding
        {
            placement.loadAd(withBidResponse: parameters.bidResponse)
        }
        else
        {
            placement.loadAd()
        }
    }
}

// MARK: - HyprMXInitializationDelegate

extension HyprMXAdapter: HyprMXInitializationDelegate
{
    func initializationDidComplete()
    {
        log(lifecycleEvent: .initializeSuccess())
        
        initializationCompletionHandler?(.initializedSuccess, nil)
        initializationCompletionHandler = nil
    }
    
    func initializationFailed()
    {
        log(lifecycleEvent: .initializeFailure())
        
        initializationCompletionHandler?(.initializedFailure, nil)
        initializationCompletionHandler = nil
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
