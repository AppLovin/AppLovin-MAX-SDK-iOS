//
//  MAAdViewSwiftUIWrapper.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/26/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import DTBiOSSDK
import SwiftUI

@available(iOS 13.0, *)
struct MAAdViewSwiftUIWrapper: UIViewRepresentable
{
    let adUnitIdentifier: String
    let adFormat: MAAdFormat
    let sdk: ALSdk
    
    @Binding var shouldLoadAd: Bool
    @Binding var isAmazonAd: Bool
    
    // MAAdViewAdDelegate methods
    var didLoad: ((MAAd) -> ())? = nil
    var didFailToLoadAd: ((String, MAError) -> ())? = nil
    var didDisplay: ((MAAd) -> ())? = nil
    var didFailToDisplayAd: ((MAAd, MAError) -> ())? = nil
    var didClick: ((MAAd) -> ())? = nil
    var didExpand: ((MAAd) -> ())? = nil
    var didCollapse: ((MAAd) -> ())? = nil
    var didHide: ((MAAd) -> ())? = nil
    
    // MAAdRequestDelegate method
    var didStartAdRequest: ((String) -> ())? = nil
    
    // MAAdRevenueDelegate method
    var didPayRevenue: ((MAAd) -> ())? = nil
    
    // DTBAdCallback methods
    var onSuccess: ((DTBAdResponse) -> ())?
    var onFailure: ((DTBAdError, DTBAdErrorInfo?) -> ())?
    
    @State private var isLoadingAd = false
    
    func makeUIView(context: Context) -> MAAdView
    {
        let adView = MAAdView(adUnitIdentifier: adUnitIdentifier, adFormat: adFormat, sdk: sdk)
        
        adView.delegate = context.coordinator
        adView.requestDelegate = context.coordinator
        adView.revenueDelegate = context.coordinator
        
        // Set background or background color for AdViews to be fully functional
        adView.backgroundColor = .black
        
        context.coordinator.adView = adView
        return adView
    }
    
    func updateUIView(_ uiView: MAAdView, context: Context)
    {
        if shouldLoadAd && !isLoadingAd
        {
            if isAmazonAd
            {
                let amazonAdSlotId: String
                let adFormat: MAAdFormat
                
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    amazonAdSlotId = "AMAZON_LEADER_SLOT_ID"
                    adFormat = MAAdFormat.leader
                }
                else
                {
                    amazonAdSlotId = "fb055f7f-c9a7-4ff5-9333-b56ce41bbe28"
                    adFormat = MAAdFormat.banner
                }
                    
                let rawSize = adFormat.size
                let size = DTBAdSize(bannerAdSizeWithWidth: Int(rawSize.width),
                                     height: Int(rawSize.height),
                                     andSlotUUID: amazonAdSlotId)!
                    
                let adLoader = DTBAdLoader()
                adLoader.setAdSizes([size])
                    
                if ALPrivacySettings.isDoNotSellSet()
                {
                    adLoader.putCustomTarget(ALPrivacySettings.isDoNotSell() ? "1YY" : "1YN", withKey: "aps_privacy")
                }
                else
                {
                    adLoader.putCustomTarget("1--", withKey: "aps_privacy")
                }
                    
                adLoader.loadAd(context.coordinator)
            }
            else
            {
                uiView.loadAd()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(parent: self)
    }
}

@available(iOS 13.0, *)
extension MAAdViewSwiftUIWrapper
{
    class Coordinator: NSObject, MAAdViewAdDelegate, MAAdRequestDelegate, MAAdRevenueDelegate, DTBAdCallback
    {
        private let parent: MAAdViewSwiftUIWrapper
        var adView: MAAdView?
        
        init(parent: MAAdViewSwiftUIWrapper)
        {
            self.parent = parent
        }
        
        func didStartAdRequest(forAdUnitIdentifier adUnitIdentifier: String)
        {
            parent.isLoadingAd = true
            parent.didStartAdRequest?(adUnitIdentifier)
        }
        
        func didLoad(_ ad: MAAd)
        {
            parent.isLoadingAd = false
            parent.didLoad?(ad)
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
        {
            parent.isLoadingAd = false
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
        
        // Handle DTBAdCallbacks
        func onSuccess(_ adResponse: DTBAdResponse!)
        {
            parent.onSuccess?(adResponse)
            
            adView?.setLocalExtraParameterForKey("amazon_ad_response", value: adResponse)
        }
        
        func onFailure(_ error: DTBAdError, dtbAdErrorInfo: DTBAdErrorInfo!)
        {
            parent.onFailure?(error, dtbAdErrorInfo)
            
            adView?.setLocalExtraParameterForKey("amazon_ad_error", value: dtbAdErrorInfo)
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

struct CallbackTableItem: Identifiable
{
    let id = UUID()
    let callback: String
}
