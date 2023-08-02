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
    @ObservedObject private var viewModel = ALMAXSwiftUITemplateNativeAdViewModel(adUnitId: "YOUR_AD_UNIT_ID")
    
    var body: some View {
        
        VStack {
            MANativeTemplateAdViewSwiftUIWrapper(triggerLoadAd: $viewModel.triggerLoadAd,
                                                 nativeAdLoader: viewModel.adLoader,
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
                viewModel.triggerLoadAd = true
            } label: {
                Text("Show")
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
    @Published var triggerLoadAd: Bool = false
    
    let adUnitIdentifier: String
    
    let adLoader: NativeSwiftUIAdLoader
    
    var containerView = UIView()
    
    init(adUnitId: String)
    {
        self.adUnitIdentifier = adUnitId
        self.adLoader = NativeSwiftUIAdLoader(adUnitId: adUnitId, containerView: containerView)
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
    // MARK: MANativeAdDelegate Protocol

    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd)
    {
        logCallback()
        
        // Save ad for clean up
        self.adLoader.nativeAd = ad
        
        if let adView = nativeAdView
        {
            // Add ad view to container view.
            self.adLoader.replaceCurrentNativeAdView(adView)
            self.containerView.addSubview(adView)
            
            // Set to false after adding the ad view to your layout if modifying constraints.
            adView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set ad view to span width and height of container and center the ad
            self.containerView.widthAnchor.constraint(equalTo: adView.widthAnchor).isActive = true
            self.containerView.heightAnchor.constraint(equalTo: adView.heightAnchor).isActive = true
            self.containerView.centerXAnchor.constraint(equalTo: adView.centerXAnchor).isActive = true
            self.containerView.centerYAnchor.constraint(equalTo: adView.centerYAnchor).isActive = true
            
            self.triggerLoadAd = false
        }
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
    }
    
    func didClickNativeAd(_ ad: MAAd)
    {
        logCallback()
    }
    
    func didExpireNativeAd(_ ad: MAAd)
    {
        logCallback()
    }
}

@available(iOS 13.0, *)
extension ALMAXSwiftUITemplateNativeAdViewModel: MAAdRevenueDelegate
{
    // MARK: MANativeAdDelegate Protocol
    
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
