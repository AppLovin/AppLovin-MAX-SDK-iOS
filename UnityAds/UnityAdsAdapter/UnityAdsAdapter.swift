//
//  UnityAdsAdapter.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import UnityAds

@objc(ALUnityAdsMediationAdapter)
final class UnityAdsAdapter: ALMediationAdapter
{
    private static let initialized = ALAtomicBoolean()
    private static var initializationStatus: MAAdapterInitializationStatus?
    
    var initializationCompletionHandler: MAAdapterInitializationCompletionHandler?
    var biddingAdIdentifier: String?
    
    // MARK: - Ads
    
    var bannerAdView: UADSBannerView?
    var adViewDelegate: UnityAdsAdViewAdapterDelegate?
    
    var interstitialDelegate: UnityAdsInterstitialAdapterDelegate?
    
    var rewardedDelegate: UnityAdsRewardedAdapterDelegate?
    
    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "UnityAds" }
    
    override var adapterVersion: String { "4.11.3.1" }
    
    override var sdkVersion: String { UnityAds.getVersion() }
    
    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        updatePrivacyConsent(for: parameters)
        
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            log(lifecycleEvent: .alreadyInitialized)
            completionHandler(Self.initializationStatus ?? .initializedUnknown, nil)
            
            return
        }
        
        let serverParameters = parameters.serverParameters
        let gameId = serverParameters["game_id"] as? String ?? ""
        
        log(lifecycleEvent: .initializing(parameters: ["game_id": gameId]))
        Self.initializationStatus = .initializing
        
        let mediationMetaData = UADSMediationMetaData()
        mediationMetaData.setName("MAX")
        mediationMetaData.setVersion(ALSdk.version())
        mediationMetaData.set("adapter_version", value: adapterVersion)
        mediationMetaData.commit()
        
        let testMode = parameters.isTesting
        UnityAds.setDebugMode(testMode)
        
        initializationCompletionHandler = completionHandler
        UnityAds.initialize(gameId, testMode: testMode, initializationDelegate: self)
    }
    
    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        bannerAdView?.delegate = nil
        bannerAdView = nil
        adViewDelegate?.delegate = nil
        adViewDelegate = nil
        
        interstitialDelegate?.delegate = nil
        interstitialDelegate = nil
        
        rewardedDelegate?.delegate = nil
        rewardedDelegate = nil
    }
    
    // MARK: - Privacy
    
    func updatePrivacyConsent(for parameters: MAAdapterParameters)
    {
        let privacyConsentMetaData = UADSMetaData()
        
        if let hasUserConsent = parameters.userConsent?.boolValue
        {
            privacyConsentMetaData.set("gdpr.consent", value: hasUserConsent)
            privacyConsentMetaData.commit()
        }
        
        // CCPA compliance - https://unityads.unity3d.com/help/legal/gdpr
        if let isDoNotSell = parameters.doNotSell?.boolValue
        {
            privacyConsentMetaData.set("privacy.consent", value: !isDoNotSell) // isDoNotSell means user has opted out and is equivalent to NO.
            privacyConsentMetaData.commit()
        }
        
        privacyConsentMetaData.set("privacy.mode", value: "mixed")
        privacyConsentMetaData.commit()
        
        if let isAgeRestrictedUser = parameters.ageRestrictedUser?.boolValue
        {
            privacyConsentMetaData.set("user.nonbehavioral", value: isAgeRestrictedUser)
            privacyConsentMetaData.commit()
        }
    }
}

// MARK: - Initialization Delegate

extension UnityAdsAdapter: UnityAdsInitializationDelegate
{
    func initializationComplete()
    {
        log(lifecycleEvent: .initializeSuccess())
        Self.initializationStatus = .initializedSuccess
        
        initializationCompletionHandler?(.initializedSuccess, nil)
        initializationCompletionHandler = nil
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String)
    {
        log(lifecycleEvent: .initializeFailure(description: message))
        Self.initializationStatus = .initializedFailure
        
        initializationCompletionHandler?(.initializedFailure, message)
        initializationCompletionHandler = nil
    }
}

// MARK: MASignalProvider

extension UnityAdsAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        log(signalEvent: .collecting)
        
        updatePrivacyConsent(for: parameters)
        
        UnityAds.getToken { [weak self] signal in
            
            guard let signal else
            {
                self?.log(signalEvent: .collectionFailed())
                delegate.didFailToCollectSignalWithErrorMessage(nil)
                
                return
            }
            
            self?.log(signalEvent: .collectionSuccess)
            delegate.didCollectSignal(signal)
        }
    }
}

// MARK: Unity Ad Load/Show options

extension MAAdapterResponseParameters
{
    func unityAdLoadOptions(with biddingAdIdentifier: String?) -> UADSLoadOptions
    {
        let options: UADSLoadOptions = .init()
        
        if !bidResponse.isEmpty
        {
            options.adMarkup = bidResponse
        }
        
        if let biddingAdIdentifier, !biddingAdIdentifier.isEmpty
        {
            options.objectId = biddingAdIdentifier
        }
        
        return options
    }
    
    func unityAdShowOptions(with biddingAdIdentifier: String?) -> UADSShowOptions
    {
        let options: UADSShowOptions = .init()
        if let biddingAdIdentifier, !biddingAdIdentifier.isEmpty
        {
            options.objectId = biddingAdIdentifier
        }
        
        return options
    }
}
