//
//  MyTargetAdapter.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 8/17/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

import AppLovinSDK
import MyTargetSDK

@objc(ALMyTargetMediationAdapter)
final class MyTargetAdapter: ALMediationAdapter
{
    private static let initialized = ALAtomicBoolean()
    
    static let mediationParameter = (key: "mediation", value: "7") // MAX specific custom parameter requested by myTarget
    
    // MARK: - Ads
    
    var interstitialAd: MTRGInterstitialAd?
    var interstitialDelegate: MyTargetInterstitialAdapterDelegate?
    
    var rewardedAd: MTRGRewardedAd?
    var rewardedDelegate: MyTargetRewardedAdapterDelegate?
    
    var adView: MTRGAdView?
    var adViewDelegate: MyTargetAdViewAdapterDelegate?
    
    var nativeAd: MTRGNativeAd?
    var nativeAdDelegate: MyTargetNativeAdAdapterDelegate?
    
    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "myTarget" }
    
    override var adapterVersion: String { "5.34.1.0" }
    
    override var sdkVersion: String { MTRGVersion.currentVersion() }
    
    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            completionHandler(.doesNotApply, nil)
            return
        }
        
        log(lifecycleEvent: .initializing())
        
        MTRGManager.setDebugMode(parameters.isTesting)
        MTRGManager.initSdk()
        
        log(lifecycleEvent: .initializeSuccess())
        
        completionHandler(.doesNotApply, nil)
    }
    
    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        interstitialAd?.delegate = nil
        interstitialAd = nil
        interstitialDelegate?.delegate = nil
        interstitialDelegate = nil
        
        rewardedAd?.delegate = nil
        rewardedAd = nil
        rewardedDelegate?.delegate = nil
        rewardedDelegate = nil
        
        adView?.delegate = nil
        adView?.viewController = nil
        adView = nil
        adViewDelegate?.delegate = nil
        adViewDelegate = nil
        
        nativeAd?.unregisterView()
        nativeAd?.delegate = nil
        nativeAd?.mediaDelegate = nil
        nativeAd = nil
        nativeAdDelegate?.delegate = nil
        nativeAdDelegate = nil
    }
    
    // MARK: - Privacy
    
    func updatePrivacyStates(for parameters: MAAdapterParameters)
    {
        if let hasUserConsent = parameters.userConsent?.boolValue
        {
            MTRGPrivacy.setUserConsent(hasUserConsent)
        }
        
        if let isDoNotSell = parameters.doNotSell?.boolValue
        {
            MTRGPrivacy.setCcpaUserConsent(isDoNotSell)
        }
    }
}

// MARK: - MASignalProvider

extension MyTargetAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        log(signalEvent: .collecting)
        
        updatePrivacyStates(for: parameters)
        
        let signal = MTRGManager.getBidderToken()
        delegate.didCollectSignal(signal)
    }
}
