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
    @ObservedObject private var viewModel = ALDemoAdViewSwiftUIViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            callbacksTable
                .frame(maxHeight: .infinity)
            
            ALAdViewSwiftUIWrapper(shouldLoadAd: $viewModel.shouldLoadAd,
                                   adLoaded: $viewModel.adLoaded,
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
                viewModel.shouldLoadAd = true
            } label: {
                Text("Load")
            }
                .disabled(viewModel.shouldLoadAd)
                .padding(.top)
        }
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    var callbacksTable: some View {
        List(viewModel.callbacks) {
            Text($0.callback)
        }
    }
}
