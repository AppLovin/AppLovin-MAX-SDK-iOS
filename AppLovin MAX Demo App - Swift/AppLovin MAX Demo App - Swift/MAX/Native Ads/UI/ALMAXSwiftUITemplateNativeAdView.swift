//
//  ALMAXSwiftUITemplateNativeAdView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/1/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import Adjust
import AppLovinSDK

@available(iOS 13.0, *)
struct ALMAXSwiftUITemplateNativeAdView: View
{
    @ObservedObject private var viewModel = ALMAXSwiftUITemplateNativeAdViewModel(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    var body: some View {
        VStack {
            ALMAXNativeTemplateAdViewSwiftUIWrapper(shouldShowAd: $viewModel.triggerShowAd,
                                                    nativeAdLoader: viewModel.nativeAdLoader,
                                                    containerView: viewModel.containerView,
                                                    didLoadNativeAd: viewModel.didLoadNativeAd(_:for:),
                                                    didFailToLoadNativeAd: viewModel.didFailToLoadNativeAd(forAdUnitIdentifier:withError:),
                                                    didClickNativeAd: viewModel.didClickNativeAd(_:),
                                                    didExpireNativeAd: viewModel.didExpireNativeAd(_:),
                                                    didPayRevenue: viewModel.didPayRevenue(for:))
                .frame(width: 300, height: 250)
            
            callbacksTable
                .frame(maxHeight: .infinity)
            
            Button {
                viewModel.triggerShowAd = true
            } label: {
                Text("Show")
                    .font(.system(size: 15))
            }
        }
    }
    
    var callbacksTable: some View {
        List(viewModel.callbacks) {
            Text($0.callback)
        }
    }
}

@available(iOS 13.0, *)
class ALMAXSwiftUITemplateNativeAdViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    @Published var triggerShowAd: Bool = false
    
    let adUnitIdentifier: String
    
    let nativeAdLoader: ALMAXNativeSwiftUIAdLoader
    
    var containerView = UIView()
    
    init(adUnitIdentifier: String)
    {
        self.adUnitIdentifier = adUnitIdentifier
        nativeAdLoader = ALMAXNativeSwiftUIAdLoader(adUnitIdentifier: adUnitIdentifier, containerView: containerView)
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
            
            triggerShowAd = false
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
