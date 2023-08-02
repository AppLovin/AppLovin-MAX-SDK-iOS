//
//  ALDemoSwiftUIBannerView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 7/31/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import Adjust
import AppLovinSDK

@available(iOS 13.0, *)
struct ALDemoSwiftUIBannerView: View
{
    @ObservedObject private var viewModel = ALDemoSwiftUIBannerViewModel()
    
    var body: some View {
        
        VStack {
            callbacksTable
                .frame(maxHeight: .infinity)
            
            AlAdViewSwiftUIWrapper(triggerLoadAd: $viewModel.triggerLoadAd,
                                   adFormat: .banner,
                                   didLoad: viewModel.adService(_:didLoad:),
                                   didFailToLoadAdWithError: viewModel.adService(_:didFailToLoadAdWithError:),
                                   wasDisplayedIn: viewModel.ad(_:wasDisplayedIn:),
                                   wasHiddenIn: viewModel.ad(_:wasHiddenIn:),
                                   wasClickedIn: viewModel.ad(_:wasClickedIn:),
                                   didPresentfullscreenFor: viewModel.ad(_:didPresentFullscreenFor:),
                                   willDismissFullscreenFor: viewModel.ad(_:willDismissFullscreenFor:),
                                   didDismissFullscreenFor: viewModel.ad(_:didDismissFullscreenFor:),
                                   willLeaveApplicationFor: viewModel.ad(_:willLeaveApplicationFor:),
                                   didReturnToApplicationFor: viewModel.ad(_:didReturnToApplicationFor:),
                                   didFailToDisplayIn: viewModel.ad(_:didFailToDisplayIn:withError:))
                .deviceSpecificFrame()
            
            Button {
                viewModel.triggerLoadAd = true
            } label: {
                Text("Load")
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
class ALDemoSwiftUIBannerViewModel: NSObject, ObservableObject
{
    @Published fileprivate var callbacks: [CallbackTableItem] = []
    @Published var triggerLoadAd: Bool = false
    
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
extension ALDemoSwiftUIBannerViewModel: ALAdLoadDelegate
{
    // MARK: ALAdLoadDelegate Protocol
    func adService(_ adService: ALAdService, didLoad ad: ALAd)
    {
        logCallback()
        self.triggerLoadAd = false
    }
    
    // Look at ALErrorCodes.h for list of error codes
    func adService(_ adService: ALAdService, didFailToLoadAdWithError code: Int32)
    {
        logCallback()
        self.triggerLoadAd = false
    }
}

@available(iOS 13.0, *)
extension ALDemoSwiftUIBannerViewModel: ALAdDisplayDelegate
{
    // MARK: ALAdDisplayDelegate Protocol
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) { logCallback() }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) { logCallback() }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) { logCallback() }
}

@available(iOS 13.0, *)
extension ALDemoSwiftUIBannerViewModel: ALAdViewEventDelegate
{
    // MARK: ALAdViewEventDelegate Protocol
    func ad(_ ad: ALAd, didPresentFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, willDismissFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didDismissFullscreenFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, willLeaveApplicationFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didReturnToApplicationFor adView: ALAdView)
    {
        logCallback()
    }
    
    func ad(_ ad: ALAd, didFailToDisplayIn adView: ALAdView, withError code: ALAdViewDisplayErrorCode)
    {
        logCallback()
    }
}
