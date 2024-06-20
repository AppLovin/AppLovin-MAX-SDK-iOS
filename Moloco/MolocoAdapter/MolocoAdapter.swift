//
//  MolocoAdapter.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/6/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@objc(ALMolocoMediationAdapter)
final class MolocoAdapter: ALMediationAdapter
{
    private static let initialized = ALAtomicBoolean()
    
    // MARK: - Ads
    
    var interstitialAd: MolocoInterstitial?
    var interstitialDelegate: MolocoInterstitialAdapterDelegate?
    
    var rewardedAd: MolocoRewardedInterstitial?
    var rewardedDelegate: MolocoRewardedAdapterDelegate?
    
    var adView: MolocoBannerAdView?
    var adViewDelegate: MolocoAdViewAdapterDelegate?
    
    var nativeAdViewAd: MAMolocoNativeAd?
    var nativeAdViewAdDelegate: MolocoNativeAdViewAdapterDelegate?
    
    var nativeAd: MolocoNativeAd?
    var nativeAdDelegate: MolocoNativeAdapterDelegate?
    
    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "Moloco" }
    
    override var adapterVersion: String { "3.0.0.0" }
    
    override var sdkVersion: String { Moloco.shared.sdkVersion }
        
    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            log(lifecycleEvent: .alreadyInitialized)
            completionHandler(.doesNotApply, nil)
            return
        }
                
        let appKey = parameters.serverParameters["app_key"] as? String ?? ""
        
        log(lifecycleEvent: .initializing())
                
        Moloco.shared.initialize(initParams: .init(appKey: appKey, mediator: .max)) { success, error in
            
            if !success || error != nil
            {
                self.log(lifecycleEvent: .initializeFailure(description: error?.localizedDescription))
                completionHandler(.initializedFailure, error?.localizedDescription)
                return
            }
            
            self.log(lifecycleEvent: .initializeSuccess())
            completionHandler(.initializedSuccess, nil)
        }
    }
    
    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        interstitialAd?.destroy()
        interstitialAd?.interstitialDelegate = nil
        interstitialAd = nil
        interstitialDelegate = nil
        
        rewardedAd?.destroy()
        rewardedAd?.rewardedDelegate = nil
        rewardedAd = nil
        rewardedDelegate = nil
        
        adView?.destroy()
        adView?.delegate = nil
        adView = nil
        adViewDelegate = nil
        
        nativeAdViewAd = nil
        nativeAdViewAdDelegate = nil
        
        nativeAd?.destroy()
        nativeAd?.delegate = nil
        nativeAd = nil
        nativeAdDelegate = nil
    }
    
    // MARK: - Privacy
    
    func updatePrivacyStates(for parameters: MAAdapterParameters)
    {
        if let userConsent = parameters.userConsent
        {
            MolocoPrivacySettings.hasUserConsent = userConsent.boolValue
        }
        
        if let isAgeRestrictedUser = parameters.ageRestrictedUser
        {
            MolocoPrivacySettings.isAgeRestrictedUser = isAgeRestrictedUser.boolValue
        }
        
        if let isDoNotSell = parameters.doNotSell
        {
            MolocoPrivacySettings.isDoNotSell = isDoNotSell.boolValue
        }
    }
}

// MARK: - MASignalProvider

extension MolocoAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        log(signalEvent: .collecting)
        
        updatePrivacyStates(for: parameters)
        
        Moloco.shared.getBidToken { signal, error in
            
            if let error
            {
                self.log(signalEvent: .collectionFailed(description: error.localizedDescription))
                delegate.didFailToCollectSignalWithErrorMessage(error.localizedDescription)
                return
            }
            
            self.log(signalEvent: .collectionSuccess)
            delegate.didCollectSignal(signal)
        }
    }
}
