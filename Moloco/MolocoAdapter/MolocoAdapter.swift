//
//  MolocoAdapter.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/6/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

@available(iOS 13.0, *)
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
    
    override var adapterVersion: String { "4.1.0.0" }
    
    override var sdkVersion: String { Moloco.shared.sdkVersion }
    
    override func initialize(with parameters: MAAdapterInitializationParameters, completionHandler: @escaping MAAdapterInitializationCompletionHandler)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "13.0", maxVersion: nil) else
        {
            log(customEvent: .unsupportedMinimumOS)
            completionHandler(.initializedFailure, "Moloco SDK does not support serving ads on iOS 12 and below")
            return
        }
        
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            completionHandler(.doesNotApply, nil)
            return
        }
        
        let appKey = parameters.serverParameters["app_key"] as? String ?? ""
        
        log(lifecycleEvent: .initializing())
        
        Moloco.shared.initialize(params: .init(appKey: appKey, mediation: "max")) { success, error in
            
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
        
        if let isDoNotSell = parameters.doNotSell
        {
            MolocoPrivacySettings.isDoNotSell = isDoNotSell.boolValue
        }
    }
}

// MARK: - MASignalProvider

@available(iOS 13.0, *)
extension MolocoAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "13.0", maxVersion: nil) else
        {
            log(customEvent: .unsupportedMinimumOS)
            delegate.didFailToCollectSignalWithErrorMessage("Moloco SDK does not support serving ads on iOS 12 and below")
            return
        }
        
        log(signalEvent: .collecting)
        
        updatePrivacyStates(for: parameters)
        
        Moloco.shared.getBidToken(params: .init(mediation: "max")) { signal, error in
            
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
