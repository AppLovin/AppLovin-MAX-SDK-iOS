//
//  MAAdViewSwiftUIWrapper.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/26/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import AppLovinSDK

@available(iOS 13.0, *)
struct MAAdViewSwiftUIWrapper: UIViewRepresentable
{
    let adUnitIdentifier: String
    let adFormat: MAAdFormat
    let sdk: ALSdk
    
    // MAAdViewAdDelegate methods
    var didLoad: ((MAAd) -> Void)? = nil
    var didFailToLoadAd: ((String, MAError) -> Void)? = nil
    var didDisplay: ((MAAd) -> Void)? = nil
    var didFailToDisplayAd: ((MAAd, MAError) -> Void)? = nil
    var didClick: ((MAAd) -> Void)? = nil
    var didExpand: ((MAAd) -> Void)? = nil
    var didCollapse: ((MAAd) -> Void)? = nil
    var didHide: ((MAAd) -> Void)? = nil
    
    // MAAdRequestDelegate method
    var didStartAdRequest: ((String) -> Void)? = nil
    
    // MAAdRevenueDelegate method
    var didPayRevenue: ((MAAd) -> Void)? = nil
    
    func makeUIView(context: Context) -> MAAdView
    {
        let adView = MAAdView(adUnitIdentifier: adUnitIdentifier, adFormat: adFormat, sdk: sdk)
        
        adView.delegate = context.coordinator
        adView.requestDelegate = context.coordinator
        adView.revenueDelegate = context.coordinator
        
        adView.loadAd()
        
        return adView
    }
    
    func updateUIView(_ uiView: MAAdView, context: Context) {}
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, *)
extension MAAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, MAAdViewAdDelegate, MAAdRequestDelegate, MAAdRevenueDelegate
    {
        private let parent: MAAdViewSwiftUIWrapper
        
        init(parent: MAAdViewSwiftUIWrapper)
        {
            self.parent = parent
        }
        
        func didStartAdRequest(forAdUnitIdentifier adUnitIdentifier: String)
        {
            parent.didStartAdRequest?(adUnitIdentifier)
        }
        
        func didLoad(_ ad: MAAd)
        {
            parent.didLoad?(ad)
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
        {
            parent.didFailToLoadAd?(adUnitIdentifier, error)
        }
        
        func didDisplay(_ ad: MAAd)
        {
            parent.didDisplay?(ad)
        }
        
        func didFail(toDisplay ad: MAAd, withError error: MAError)
        {
            parent.didFailToDisplayAd?(ad, error)
        }
        
        func didClick(_ ad: MAAd)
        {
            parent.didClick?(ad)
        }
        
        func didExpand(_ ad: MAAd)
        {
            parent.didExpand?(ad)
        }
        
        func didCollapse(_ ad: MAAd)
        {
            parent.didCollapse?(ad)
        }
        
        func didHide(_ ad: MAAd)
        {
            parent.didHide?(ad)
        }
        
        func didPayRevenue(for ad: MAAd)
        {
            parent.didPayRevenue?(ad)
        }
    }
}

@available(iOS 13.0, *)
extension MAAdViewSwiftUIWrapper
{
    func deviceSpecificFrame() -> some View
    {
        modifier(MAAdViewFrame(adFormat: adFormat))
    }
}

@available(iOS 13.0.0, *)
struct MAAdViewFrame: ViewModifier
{
    let adFormat: MAAdFormat
    private let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    func body(content: Content) -> some View
    {
        if ( adFormat == .banner )
        {
            content
                .frame(width: isPhone ? MAAdFormat.banner.size.width : MAAdFormat.leader.size.width,
                       height: isPhone ? MAAdFormat.banner.size.height : MAAdFormat.leader.size.height)
        }
        else // adFormat == .mrec
        {
            content
                .frame(width: 300, height: 250)
        }
    }
}

struct MAAdViewCallbackTableItem: Identifiable
{
    let id = UUID()
    let callback: String
}
