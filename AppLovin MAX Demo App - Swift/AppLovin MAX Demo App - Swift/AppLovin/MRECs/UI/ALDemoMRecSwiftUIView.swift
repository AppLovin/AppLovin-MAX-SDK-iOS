//
//  ALDemoMRecSwiftUIView.swift
//  AppLovin MAX Demo App - Swift
//
//  Created by Matthew Nguyen on 7/31/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import SwiftUI
import Adjust
import AppLovinSDK

@available(iOS 13.0, *)
struct ALDemoSwiftUIMRecView: View
{
    @ObservedObject private var mrecViewModel = ALDemoAdViewSwiftUIViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ALAdViewSwiftUIWrapper(shouldLoadAd: $mrecViewModel.shouldLoadAd,
                                   adLoaded: $mrecViewModel.adLoaded,
                                   adFormat: .mrec,
                                   didLoad: mrecViewModel.adService(_:didLoad:),
                                   didFailToLoadAdWithError: mrecViewModel.adService(_:didFailToLoadAdWithError:),
                                   wasDisplayedIn: mrecViewModel.ad(_:wasDisplayedIn:),
                                   wasHiddenIn: mrecViewModel.ad(_:wasHiddenIn:),
                                   wasClickedIn: mrecViewModel.ad(_:wasClickedIn:),
                                   didPresentfullscreenFor: mrecViewModel.ad(_:didPresentFullscreenFor:),
                                   willDismissFullscreenFor: mrecViewModel.ad(_:willDismissFullscreenFor:),
                                   didDismissFullscreenFor: mrecViewModel.ad(_:didDismissFullscreenFor:),
                                   willLeaveApplicationFor: mrecViewModel.ad(_:willLeaveApplicationFor:),
                                   didReturnToApplicationFor: mrecViewModel.ad(_:didReturnToApplicationFor:),
                                   didFailToDisplayIn: mrecViewModel.ad(_:didFailToDisplayIn:withError:))
                .deviceSpecificFrame()
            
            callbacksTable
                .frame(maxHeight: .infinity)
            
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                Button {
                    mrecViewModel.shouldLoadAd = true
                } label: {
                    Text("Load")
                }
                    .disabled(mrecViewModel.shouldLoadAd)
            }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: 44
                )
                .padding(.top)
        }
    }
    
    var callbacksTable: some View {
        List(mrecViewModel.callbacks) {
            Text($0.callback)
        }
    }
}
