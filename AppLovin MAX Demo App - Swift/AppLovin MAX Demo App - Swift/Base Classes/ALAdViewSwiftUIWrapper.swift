//
//  ALAdViewSwiftUIWrapper.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 7/31/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import AppLovinSDK

@available(iOS 13.0, *)
struct ALAdViewSwiftUIWrapper: UIViewRepresentable
{
    @Binding var shouldLoadAd: Bool
    @Binding var adLoaded: Bool
    
    let adFormat: ALAdSize
    
    // ALAdLoadDelegate methods
    var didLoad: ((ALAdService, ALAd) -> Void)? = nil
    var didFailToLoadAdWithError: ((ALAdService, Int32) -> Void)? = nil
    
    // ALAdDisplayDelegate methods
    var wasDisplayedIn: ((ALAd, UIView) -> Void)? = nil
    var wasHiddenIn: ((ALAd, UIView) -> Void)? = nil
    var wasClickedIn: ((ALAd, UIView) -> Void)? = nil
    
    // ALAdViewEventDelegate methods
    var didPresentFullscreenFor: ((ALAd, ALAdView) -> Void)? = nil
    var willDismissFullscreenFor: ((ALAd, ALAdView) -> Void)? = nil
    var didDismissFullscreenFor: ((ALAd, ALAdView) -> Void)? = nil
    var willLeaveApplicationFor: ((ALAd, ALAdView) -> Void)? = nil
    var didReturnToApplicationFor: ((ALAd, ALAdView) -> Void)? = nil
    var didFailToDisplayIn: ((ALAd, ALAdView, ALAdViewDisplayErrorCode) -> Void)? = nil
    
    func makeUIView(context: Context) -> ALAdView
    {
        let adView = ALAdView(size: adFormat)
        adView.adLoadDelegate = context.coordinator
        adView.adDisplayDelegate = context.coordinator
        adView.adEventDelegate = context.coordinator
        
        // Set background or background color for AdViews to be fully functional
        adView.backgroundColor = .black
        
        // Load the first ad
        adView.loadNextAd()
        
        return adView
    }
    
    func updateUIView(_ uiView: ALAdView, context: Context)
    {
        if shouldLoadAd && !adLoaded
        {
            uiView.loadNextAd()
        }
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, *)
extension ALAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate, ObservableObject
    {
        private let parent: ALAdViewSwiftUIWrapper
        
        init(parent: ALAdViewSwiftUIWrapper)
        {
            self.parent = parent
        }
        
        // ALAdLoadDelegate methods
        func adService(_ adService: ALAdService, didLoad ad: ALAd)
        {
            parent.didLoad?(adService, ad)
        }
        
        func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
        {
            parent.didFailToLoadAdWithError?(adService, code)
        }
        
        // ALAdDisplayDelegate methods
        func ad(_ ad: ALAd, wasDisplayedIn view: UIView)
        {
            parent.wasDisplayedIn?(ad, view)
        }
        
        func ad(_ ad: ALAd, wasHiddenIn view: UIView)
        {
            parent.wasHiddenIn?(ad, view)
        }
        
        func ad(_ ad: ALAd, wasClickedIn view: UIView)
        {
            parent.wasClickedIn?(ad, view)
        }
        
        // ALAdViewEventDelegate methods
        func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView)
        {
            parent.didPresentFullscreenFor?(ad, adView)
        }
        
        func ad(_ ad: ALAd, willDismissFullscreenFor adView: ALAdView)
        {
            parent.willDismissFullscreenFor?(ad, adView)
        }
        
        func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView)
        {
            parent.didDismissFullscreenFor?(ad, adView)
        }
        
        func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView)
        {
            parent.willLeaveApplicationFor?(ad, adView)
        }
        
        func ad(_ ad: ALAd, didReturnToApplicationFor adView: ALAdView)
        {
            parent.didReturnToApplicationFor?(ad, adView)
        }
        
        func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode)
        {
            parent.didFailToDisplayIn?(ad, adView, code)
        }
    }
}

@available(iOS 13.0, *)
extension ALAdViewSwiftUIWrapper
{
    func deviceSpecificFrame() -> some View
    {
        modifier(ALAdViewFrame(adFormat: adFormat))
    }
}

@available(iOS 13.0.0, *)
struct ALAdViewFrame: ViewModifier
{
    let adFormat: ALAdSize
    
    func body(content: Content) -> some View
    {
        if adFormat == .banner || adFormat == .leader
        {
            // Stretch to the width of the screen for banners to be fully functional
            // Banner height on iPhone and iPad is 50 and 90, respectively
            content
                .frame(height: (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50)
        }
        else // adFormat == .mrec
        {
            // MREC width and height are 300 and 250 respectively, on iPhone and iPad
            content
                .frame(width: 300, height: 250)
        }
    }
}
