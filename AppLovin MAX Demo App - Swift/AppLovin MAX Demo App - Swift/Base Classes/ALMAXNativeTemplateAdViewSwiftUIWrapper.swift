//
//  ALMAXNativeTemplateAdViewSwiftUIWrapper.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 7/31/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import AppLovinSDK

@available(iOS 13.0, *)
struct ALMAXNativeTemplateAdViewSwiftUIWrapper: UIViewRepresentable
{
    @Binding var shouldShowAd: Bool
    
    let nativeAdLoader: ALMAXNativeSwiftUIAdLoader
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
        if shouldShowAd
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
extension ALMAXNativeTemplateAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, MANativeAdDelegate, MAAdRevenueDelegate
    {
        private let parent: ALMAXNativeTemplateAdViewSwiftUIWrapper
        
        init(parent: ALMAXNativeTemplateAdViewSwiftUIWrapper)
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
class ALMAXNativeSwiftUIAdLoader
{
    weak var containerView: UIView?
    var nativeAdLoader: MANativeAdLoader
    var nativeAd: MAAd?
    var nativeAdView: MANativeAdView?
    
    init(adUnitIdentifier: String, containerView: UIView)
    {
        self.containerView = containerView
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: adUnitIdentifier)
    }
    
    func setNativeAdDelegate(_ context: UIViewRepresentableContext<ALMAXNativeTemplateAdViewSwiftUIWrapper>)
    {
        nativeAdLoader.nativeAdDelegate = context.coordinator
    }
    
    func setRevenueDelegate(_ context: UIViewRepresentableContext<ALMAXNativeTemplateAdViewSwiftUIWrapper>)
    {
        nativeAdLoader.revenueDelegate = context.coordinator
    }
    
    func replaceCurrentNativeAdView(_ newNativeAdView: MANativeAdView)
    {
        nativeAdView = newNativeAdView
        
        containerView?.addSubview(newNativeAdView)
    }
    
    func cleanUpAdIfNeeded()
    {
        if let currentNativeAd = nativeAd
        {
            nativeAdLoader.destroy(currentNativeAd)
        }
        
        if let currentNativeAdView = nativeAdView
        {
            currentNativeAdView.removeFromSuperview()
        }
    }
    
    func showAd()
    {
        cleanUpAdIfNeeded()
        
        nativeAdLoader.loadAd()
    }
}
