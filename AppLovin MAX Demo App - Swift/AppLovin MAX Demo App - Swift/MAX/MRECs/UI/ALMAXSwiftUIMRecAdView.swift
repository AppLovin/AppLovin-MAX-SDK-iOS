//
//  ALMAXSwiftUIMRecAdView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Wootae Jeon on 1/27/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AdjustSdk
import AppLovinSDK
import SwiftUI

@available(iOS 13.0, *)
struct ALMAXSwiftUIMRecAdView: View
{
    @ObservedObject private var viewModel = ALMAXSwiftUIMRecAdViewModel()
    
    var body: some View
    {
        VStack {
            MAAdViewSwiftUIWrapper(adUnitIdentifier: "YOUR_AD_UNIT_ID",
                                   adFormat: .mrec,
                                   sdk: ALSdk.shared(),
                                   didLoad: viewModel.didLoad,
                                   didFailToLoadAd: viewModel.didFailToLoadAd,
                                   didDisplay: viewModel.didDisplay,
                                   didFailToDisplayAd: viewModel.didFail,
                                   didClick: viewModel.didClick,
                                   didExpand: viewModel.didExpand,
                                   didCollapse: viewModel.didCollapse,
                                   didHide: viewModel.didHide,
                                   didPayRevenue: viewModel.didPayRevenue)
                .deviceSpecificFrame()
            
            callbacksTable
                .frame(maxHeight: .infinity)
        }
    }
    
    var callbacksTable: some View
    {
        List(viewModel.callbacks) {
            Text($0.callback)
        }
    }
}

@available(iOS 13.0, *)
class ALMAXSwiftUIMRecAdViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    
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
extension ALMAXSwiftUIMRecAdViewModel: MAAdViewAdDelegate, MAAdRevenueDelegate
{
    // MARK: MAAdDelegate Protocol
    func didLoad(_ ad: MAAd) { logCallback() }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) { logCallback() }
    
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
        
        let adjustAdRevenue = ADJAdRevenue(source: "applovin_max_sdk")!
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
