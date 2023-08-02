//
//  MANativeTemplateAdViewSwiftUIWrapper.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 7/31/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import AppLovinSDK

@available(iOS 13.0, *)
struct MANativeTemplateAdViewSwiftUIWrapper: UIViewRepresentable
{
    @Binding var triggerShowAd: Bool
    let nativeAdLoader: NativeSwiftUIAdLoader
    let containerView: UIView
    
    // MANativeAdDelegate methods
    var didLoadNativeAd: ((MANativeAdView?, MAAd) -> Void)? = nil
    var didFailToLoadNativeAd: ((String, MAError) -> Void)? = nil
    var didClickNativeAd: ((MAAd) -> Void)? = nil
    var didExpireNativeAd: ((MAAd) -> Void)? = nil
    
    // MAAdRevenueDelegate methods
    var didPayRevenue: ((MAAd) -> Void)? = nil
        
    
    func makeUIView(context: Context) -> UIView
    {
        nativeAdLoader.setNativeAdDelegate(context)
        nativeAdLoader.setRevenueDelegate(context)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context)
    {
        if triggerShowAd
        {
            nativeAdLoader.showAd()
        }
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, *)
extension MANativeTemplateAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, MANativeAdDelegate, MAAdRevenueDelegate
    {
        private let parent: MANativeTemplateAdViewSwiftUIWrapper
        
        init(parent: MANativeTemplateAdViewSwiftUIWrapper)
        {
            self.parent = parent
        }
        
        // MANativeAdDelegate methods
        func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd)
        {
            parent.didLoadNativeAd?(maxNativeAdView, ad)
        }
        
        func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
        {
            parent.didFailToLoadNativeAd?(adUnitIdentifier, error)
        }
        
        func didClickNativeAd(_ ad: MAAd)
        {
            parent.didClickNativeAd?(ad)
        }
        
        func didExpireNativeAd(_ ad: MAAd)
        {
            parent.didExpireNativeAd?(ad)
        }
        
        // MAAdRevenueDelegate methods
        func didPayRevenue(for ad: MAAd)
        {
            parent.didPayRevenue?(ad)
        }
    }
}

@available(iOS 13.0, *)
class NativeSwiftUIAdLoader
{
    var adUnitId: String
    weak var containerView: UIView?
    var nativeAdLoader: MANativeAdLoader?
    var nativeAd: MAAd?
    var nativeAdView: MANativeAdView?
    
    init(adUnitId: String, containerView: UIView)
    {
        self.adUnitId = adUnitId
        self.containerView = containerView
        self.nativeAdLoader = MANativeAdLoader(adUnitIdentifier: adUnitId)
    }
    
    func setNativeAdDelegate(_ context: UIViewRepresentableContext<MANativeTemplateAdViewSwiftUIWrapper>)
    {
        self.nativeAdLoader?.nativeAdDelegate = context.coordinator
    }
    
    func setRevenueDelegate(_ context: UIViewRepresentableContext<MANativeTemplateAdViewSwiftUIWrapper>)
    {
        self.nativeAdLoader?.revenueDelegate = context.coordinator
    }
    
    func replaceCurrentNativeAdView(_ newNativeAdView: MANativeAdView)
    {
        self.nativeAdView = newNativeAdView
        self.containerView?.addSubview(newNativeAdView)
    }
    
    func cleanUpAdIfNeeded()
    {
        if let currentNativeAd = nativeAd
        {
            self.nativeAdLoader?.destroy(currentNativeAd)
        }
        
        if let currentNativeAdView = nativeAdView
        {
            currentNativeAdView.removeFromSuperview()
        }
    }
    
    func showAd()
    {
        cleanUpAdIfNeeded()
        
        self.nativeAdLoader?.loadAd()
    }
}
