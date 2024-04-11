//
//  Error+Extensions.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 9/11/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import MolocoSDK

extension Error
{
    var molocoAdapterError: MAAdapterError
    {
        guard let molocoError = self as? MolocoError else
        {
            return .init(adapterError: .unspecified, mediatedNetworkErrorCode: code, mediatedNetworkErrorMessage: localizedDescription)
        }
        
        let adapterError: MAAdapterError
        switch molocoError
        {
        case .unknown:
            adapterError = .unspecified
        case .adLoadFailedSDKNotInit, .sdkInit:
            adapterError = .notInitialized
        case .sdkInvalidConfiguration:
            adapterError = .invalidConfiguration
        case .adLoadFailed:
            adapterError = .noFill
        case .adLoadTimeoutError:
            adapterError = .timeout
        case .adShowFailed, .adShowFailedAlreadyDisplaying:
            adapterError = .adDisplayFailedError
        case .adShowFailedNotLoaded:
            adapterError = .adNotReady
        case .adBidParseFailed:
            adapterError = .invalidLoadState
        case .adSignalCollectionFailed:
            adapterError = .signalCollectionTimeout
        @unknown default:
            adapterError = .unspecified
        }
        
        return .init(adapterError: adapterError,
                     mediatedNetworkErrorCode: code,
                     mediatedNetworkErrorMessage: localizedDescription)
    }
    
    var molocoNativeAdapterError: MAAdapterError
    {
        guard let molocoNativeAdError = self as? MolocoNativeAdError else
        {
            return .init(adapterError: .unspecified, mediatedNetworkErrorCode: code, mediatedNetworkErrorMessage: localizedDescription)
        }
        
        let adapterError: MAAdapterError
        switch molocoNativeAdError
        {
        case .placementNeedsCustomLayout:
            adapterError = .invalidConfiguration
        @unknown default:
            adapterError = .unspecified
        }
        
        return .init(adapterError: adapterError,
                     mediatedNetworkErrorCode: code,
                     mediatedNetworkErrorMessage: localizedDescription)
    }
}
