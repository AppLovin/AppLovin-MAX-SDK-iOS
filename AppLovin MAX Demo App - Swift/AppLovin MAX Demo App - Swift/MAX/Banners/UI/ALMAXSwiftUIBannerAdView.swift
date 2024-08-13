//
//  ALMAXSwiftUIBannerAdView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/26/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import Adjust
import AppLovinSDK
import DTBiOSSDK
import SwiftUI

@available(iOS 13.0, *)
struct ALMAXSwiftUIBannerAdView: View
{
    @ObservedObject private var viewModel = ALMAXSwiftUIBannerAdViewModel()
    
    var body: some View
    {
        VStack {
            MAAdViewSwiftUIWrapper(adUnitIdentifier: "YOUR_AD_UNIT_ID",
                                   adFormat: .banner,
                                   sdk: ALSdk.shared(),
                                   shouldLoadAd: $viewModel.isLoading,
                                   isAmazonAd: $viewModel.isAmazonAd,
                                   didLoad: viewModel.didLoad,
                                   didFailToLoadAd: viewModel.didFailToLoadAd,
                                   didDisplay: viewModel.didDisplay,
                                   didFailToDisplayAd: viewModel.didFail,
                                   didClick: viewModel.didClick,
                                   didExpand: viewModel.didExpand,
                                   didCollapse: viewModel.didCollapse,
                                   didHide: viewModel.didHide,
                                   didPayRevenue: viewModel.didPayRevenue,
                                   onSuccess: viewModel.onSuccess,
                                   onFailure: viewModel.onFailure)
                .deviceSpecificFrame()
            
            callbacksTable
                .frame(maxHeight: .infinity)
            controlsView
                .padding()
        }
    }
    
    var callbacksTable: some View
    {
        List(viewModel.callbacks) {
            Text($0.callback)
        }
    }
    
    var controlsView: some View
    {
        VStack(spacing: 15) {
            Toggle("Load Amazon Bid", isOn: $viewModel.isAmazonAd)
            
            Button {
                viewModel.isLoading = true
            } label: {
                if viewModel.isLoading
                {
                    if #available(iOS 14.0, *)
                    {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    else
                    {
                        Text("Loading...")
                    }
                }
                else
                {
                    Text("Load")
                }
            }
            .buttonStyle(AppLovinButtonStyle())
        }
    }
}

@available(iOS 13.0, *)
class ALMAXSwiftUIBannerAdViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    @Published fileprivate var isAmazonAd = false
    @Published fileprivate var isLoading = false
    
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
extension ALMAXSwiftUIBannerAdViewModel: DTBAdCallback
{
    // MARK: DTBAdCallback Protocol
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        logCallback()
        isLoading = false
    }
    
    func onFailure(_ error: DTBAdError, dtbAdErrorInfo: DTBAdErrorInfo!)
    {
        logCallback()
        isLoading = false
    }
}

@available(iOS 13.0, *)
extension ALMAXSwiftUIBannerAdViewModel: MAAdViewAdDelegate, MAAdRevenueDelegate
{
    // MARK: MAAdDelegate Protocol
    func didLoad(_ ad: MAAd)
    {
        logCallback()
        isLoading = false
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        logCallback()
        isLoading = false
    }
    
    func didDisplay(_ ad: MAAd) { logCallback() }
    
    func didHide(_ ad: MAAd) { logCallback() }
    
    func didClick(_ ad: MAAd) { logCallback() }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) { logCallback() }
    
    // MARK: MAAdViewAdDelegate Protocol
    func didExpand(_ ad: MAAd) { logCallback() }
    
    func didCollapse(_ ad: MAAd) { logCallback() }
    
    // MARK: MAAdRevenueDelegate Protocol
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

@available(iOS 13.0, *)
struct AppLovinButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        let height = 36.0
        let cornerRadius = 7.0
        let buttonColor = UIColor.init(red: 0.09, green: 0.52, blue: 0.66, alpha: 1.0)
        
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(
                Color(buttonColor)
                    .frame(height: height)
                    .cornerRadius(cornerRadius))
    }
}
