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

@available(iOS 14.0, *)
struct ALDemoSwiftUIBannerView: View
{
    @ObservedObject private var bannerViewModel = ALDemoAdViewSwiftUIViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                callbacksTable
                    .frame(maxHeight: .infinity)
                
                ALAdViewSwiftUIWrapper(shouldLoadAd: $bannerViewModel.shouldLoadAd,
                                       adLoaded: $bannerViewModel.adLoaded,
                                       adFormat: .banner,
                                       didLoad: bannerViewModel.adService(_:didLoad:),
                                       didFailToLoadAdWithError: bannerViewModel.adService(_:didFailToLoadAdWithError:),
                                       wasDisplayedIn: bannerViewModel.ad(_:wasDisplayedIn:),
                                       wasHiddenIn: bannerViewModel.ad(_:wasHiddenIn:),
                                       wasClickedIn: bannerViewModel.ad(_:wasClickedIn:),
                                       didPresentFullscreenFor: bannerViewModel.ad(_:didPresentFullscreenFor:),
                                       willDismissFullscreenFor: bannerViewModel.ad(_:willDismissFullscreenFor:),
                                       didDismissFullscreenFor: bannerViewModel.ad(_:didDismissFullscreenFor:),
                                       willLeaveApplicationFor: bannerViewModel.ad(_:willLeaveApplicationFor:),
                                       didReturnToApplicationFor: bannerViewModel.ad(_:didReturnToApplicationFor:),
                                       didFailToDisplayIn: bannerViewModel.ad(_:didFailToDisplayIn:withError:))
                .deviceSpecificFrame()
                
                Button {
                    bannerViewModel.shouldLoadAd = true
                } label: {
                    Text("Load")
                }
                .disabled(bannerViewModel.shouldLoadAd)
                .padding(.top)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .navigationTitle(Text("SwiftUI Banners"))
    }
    
    var callbacksTable: some View {
        List(bannerViewModel.callbacks) {
            Text($0.callback)
        }
    }
}
