//
//  ALDemoSwiftUILeaderView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 8/9/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import Adjust
import AppLovinSDK

@available(iOS 14.0, *)
struct ALDemoSwiftUILeaderView: View
{
    @ObservedObject private var leaderViewModel = ALDemoAdViewSwiftUIViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                callbacksTable
                    .frame(maxHeight: .infinity)
                
                ALAdViewSwiftUIWrapper(shouldLoadAd: $leaderViewModel.shouldLoadAd,
                                       adLoaded: $leaderViewModel.adLoaded,
                                       adFormat: .leader,
                                       didLoad: leaderViewModel.adService(_:didLoad:),
                                       didFailToLoadAdWithError: leaderViewModel.adService(_:didFailToLoadAdWithError:),
                                       wasDisplayedIn: leaderViewModel.ad(_:wasDisplayedIn:),
                                       wasHiddenIn: leaderViewModel.ad(_:wasHiddenIn:),
                                       wasClickedIn: leaderViewModel.ad(_:wasClickedIn:),
                                       didPresentFullscreenFor: leaderViewModel.ad(_:didPresentFullscreenFor:),
                                       willDismissFullscreenFor: leaderViewModel.ad(_:willDismissFullscreenFor:),
                                       didDismissFullscreenFor: leaderViewModel.ad(_:didDismissFullscreenFor:),
                                       willLeaveApplicationFor: leaderViewModel.ad(_:willLeaveApplicationFor:),
                                       didReturnToApplicationFor: leaderViewModel.ad(_:didReturnToApplicationFor:),
                                       didFailToDisplayIn: leaderViewModel.ad(_:didFailToDisplayIn:withError:))
                .deviceSpecificFrame()
                
                Button {
                    leaderViewModel.shouldLoadAd = true
                } label: {
                    Text("Load")
                }
                .disabled(leaderViewModel.shouldLoadAd)
                .padding(.top)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .navigationTitle(Text("SwiftUI Leaders"))
    }
    
    var callbacksTable: some View {
        List(leaderViewModel.callbacks) {
            Text($0.callback)
        }
    }
}
