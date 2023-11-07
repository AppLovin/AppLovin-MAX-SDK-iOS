//
//  ALDemoAdViewSwiftUIViewModel.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/8/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import SwiftUI

@available(iOS 13.0, *)
class ALDemoAdViewSwiftUIViewModel: NSObject, ObservableObject
{
    @Published var callbacks: [CallbackTableItem] = []
    @Published var shouldLoadAd: Bool = true
    @Published var adLoaded: Bool = false
    
    private func logCallback(functionName: String = #function)
    {
        DispatchQueue.main.async {
            withAnimation {
                self.callbacks.append(CallbackTableItem(callback: functionName))
            }
        }
    }
}

@available(iOS 13.0, *)
extension ALDemoAdViewSwiftUIViewModel: ALAdLoadDelegate
{
    // MARK: ALAdLoadDelegate
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()
        
        adLoaded = true
    }
    
    // Look at ALErrorCodes.h for list of error codes
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        logCallback()
        
        shouldLoadAd = false
        adLoaded = false
    }
}

@available(iOS 13.0, *)
extension ALDemoAdViewSwiftUIViewModel: ALAdDisplayDelegate
{
    // MARK: ALAdDisplayDelegate
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView)
    {
        logCallback()
        
        shouldLoadAd = false
        adLoaded = false
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) { logCallback() }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) { logCallback() }
}

@available(iOS 13.0, *)
extension ALDemoAdViewSwiftUIViewModel: ALAdViewEventDelegate
{
    // MARK: ALAdViewEventDelegate
    func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView) { logCallback() }
    
    func ad(_ ad: ALAd, willDismissFullscreenFor adView: ALAdView) { logCallback() }
    
    func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView) { logCallback() }
    
    func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView) { logCallback() }
    
    func ad(_ ad: ALAd, didReturnToApplicationFor adView: ALAdView) { logCallback() }
    
    func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode) { logCallback() }
}
