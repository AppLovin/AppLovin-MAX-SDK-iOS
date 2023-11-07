//
//  ALMAXSwiftUITemplateNativeAdView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/1/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import Adjust
import AppLovinSDK
import SwiftUI

@available(iOS 14.0, *)
struct ALMAXSwiftUITemplateNativeAdView: View
{
    @ObservedObject private var templateNativeViewModel = ALMAXSwiftUITemplateNativeAdViewModel(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    var body: some View
    {
        NavigationView {
            VStack {
                ALMAXNativeTemplateAdViewSwiftUIWrapper(shouldShowAd: $templateNativeViewModel.shouldShowAd,
                                                        nativeAdLoader: templateNativeViewModel.nativeAdLoader,
                                                        containerView: templateNativeViewModel.containerView,
                                                        didLoadNativeAd: templateNativeViewModel.didLoadNativeAd(_:for:),
                                                        didFailToLoadNativeAd: templateNativeViewModel.didFailToLoadNativeAd(forAdUnitIdentifier:withError:),
                                                        didClickNativeAd: templateNativeViewModel.didClickNativeAd(_:),
                                                        didExpireNativeAd: templateNativeViewModel.didExpireNativeAd(_:),
                                                        didPayRevenue: templateNativeViewModel.didPayRevenue(for:))
                    .frame(width: 300, height: 250)
                
                callbacksTable
                    .frame(maxHeight: .infinity)
                
                Button {
                    templateNativeViewModel.shouldShowAd = true
                } label: {
                    Text("Show")
                        .font(.system(size: 15))
                }
            }
        }
        .navigationTitle(Text("SwiftUI Templates API"))
    }
    
    var callbacksTable: some View
    {
        List(templateNativeViewModel.callbacks) {
            Text($0.callback)
        }
    }
}

@available(iOS 13.0, *)
class ALMAXSwiftUITemplateNativeAdViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    @Published var shouldShowAd: Bool = false
    
    let nativeAdLoader: ALMAXNativeSwiftUIAdLoader
    
    var containerView = UIView()
    
    init(adUnitIdentifier: String)
    {
        self.nativeAdLoader = ALMAXNativeSwiftUIAdLoader(adUnitIdentifier: adUnitIdentifier, containerView: containerView)
    }
    
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
extension ALMAXSwiftUITemplateNativeAdViewModel: MANativeAdDelegate
{
    // MARK: MANativeAdDelegate
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd)
    {
        logCallback()
        
        // Save ad for clean up
        nativeAdLoader.nativeAd = ad
        
        if let adView = nativeAdView
        {
            // Add ad view to container view.
            nativeAdLoader.replaceCurrentNativeAdView(adView)
            containerView.addSubview(adView)
            
            // Set to false after adding the ad view to your layout if modifying constraints.
            adView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set ad view to span width and height of container and center the ad
            containerView.widthAnchor.constraint(equalTo: adView.widthAnchor).isActive = true
            containerView.heightAnchor.constraint(equalTo: adView.heightAnchor).isActive = true
            containerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            containerView.centerYAnchor.constraint(equalTo: adView.centerYAnchor).isActive = true
            
            shouldShowAd = false
        }
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) { logCallback() }
    
    func didClickNativeAd(_ ad: MAAd) { logCallback() }
    
    func didExpireNativeAd(_ ad: MAAd) { logCallback() }
}

@available(iOS 13.0, *)
extension ALMAXSwiftUITemplateNativeAdViewModel: MAAdRevenueDelegate
{
    // MARK: MANativeAdDelegate
    func didPayRevenue(for ad: MAAd)
    {
        logCallback()
        
        let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX)!
        adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
        adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
        adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
        
        if let placement = ad.placement
        {
            adjustAdRevenue.setAdRevenuePlacement(placement)
        }
        
        Adjust.trackAdRevenue(adjustAdRevenue)
    }
}
