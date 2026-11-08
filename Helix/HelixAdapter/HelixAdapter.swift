//
//  HelixAdapter.swift
//  HelixAdapter
//
//  Created by Nana Amoah on 9/25/26.
//  Copyright © 2026 AppLovin. All rights reserved.
//

import AppLovinSDK
import VoodooAdn

@available(iOS 14.0, *)
@objc(ALVoodooAdapter)
final class HelixAdapter: ALMediationAdapter
{
    private static let initialized = ALAtomicBoolean()
    private static let mediationName = "maxads"
    
    // MARK: - Ads
    
    var interstitialAd: AdnSdk.AdUnit?
    var interstitialDelegate: HelixInterstitialAdapterDelegate?
    
    var rewardedAd: AdnSdk.AdUnit?
    var rewardedDelegate: HelixRewardedAdapterDelegate?
    
    // MARK: - Overrides
    
    override var thirdPartySdkName: String { "Helix" }
    
    override var adapterVersion: String { "3.17.0.0" }
    
    override var sdkVersion: String { AdnSdk.version }
    
    override func initialize(with parameters: MAAdapterInitializationParameters) async -> (MAAdapterInitializationStatus, String?)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        let systemVersion = await UIDevice.current.systemVersion
        guard ALUtils.isInclusiveVersion(systemVersion, forMinVersion: "14.0", maxVersion: nil) else
        {
            logInfo("Current iOS version is: \(systemVersion), but Helix requires minimum iOS 14.0")
            return (.initializedFailure, "Helix SDK does not support serving ads on iOS 13 and below")
        }
        
        guard Self.initialized.compareAndSet(false, update: true) else
        {
            return (.doesNotApply, nil)
        }
        
        log(lifecycleEvent: .initializing())
        
        do
        {
            try await AdnSdk.initialize(options: .withMediationName(Self.mediationName))
            log(lifecycleEvent: .initializeSuccess())
            return (.initializedSuccess, nil)
        }
        catch
        {
            log(lifecycleEvent: .initializeFailure(description: error.localizedDescription))
            return (.initializedFailure, error.localizedDescription)
        }
    }
    
    override func destroy()
    {
        log(lifecycleEvent: .destroy)
        
        interstitialAd = nil
        interstitialDelegate = nil
        
        rewardedAd = nil
        rewardedDelegate = nil
    }
    
    func updatePrivacyStates(for parameters: MAAdapterParameters)
    {
        if let isDoNotSell = parameters.doNotSell
        {
            AdnSdk.setDoNotSell(isDoNotSell.boolValue)
        }
    }
}

// MARK: - MASignalProvider

@available(iOS 14.0, *)
extension HelixAdapter: MASignalProvider
{
    func collectSignal(with parameters: MASignalCollectionParameters, andNotify delegate: MASignalCollectionDelegate)
    {
        // NOTE: We need this extra guard because the SDK bypasses the @available check when this function is called from Objective-C
        guard ALUtils.isInclusiveVersion(UIDevice.current.systemVersion, forMinVersion: "14.0", maxVersion: nil) else
        {
            logInfo("Current iOS version is: \(UIDevice.current.systemVersion), but Helix requires minimum iOS 14.0")
            delegate.didFailToCollectSignalWithErrorMessage("Helix SDK does not support serving ads on iOS 13 and below")
            return
        }
        
        log(signalEvent: .collecting)
        
        updatePrivacyStates(for: parameters)
        
        AdnSdk.getToken(adType: parameters.adFormat.label) { token in
            self.log(signalEvent: .collectionSuccess)
            delegate.didCollectSignal(token)
        }
    }
}
