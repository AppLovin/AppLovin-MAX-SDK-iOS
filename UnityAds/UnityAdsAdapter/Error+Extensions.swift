//
//  Error+Extensions.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK
import UnityAds

extension UnityAdsLoadError
{
    func unityAdsAdapterError(with message: String) -> MAAdapterError
    {
        let adapterError: MAAdapterError = switch self
        {
        case .initializeFailed: .notInitialized
        case .internal: .internalError
        case .invalidArgument: .invalidConfiguration
        case .noFill: .noFill
        case .timeout: .timeout
        @unknown default: .unspecified
        }
        
        return .init(adapterError: adapterError,
                     mediatedNetworkErrorCode: rawValue,
                     mediatedNetworkErrorMessage: message)
    }
}

extension UnityAdsShowError
{
    func unityAdsAdapterError(with message: String) -> MAAdapterError
    {
        let adapterError: MAAdapterError = switch self
        {
        case .showErrorNotInitialized: .notInitialized
        case .showErrorNotReady: .adNotReady
        case .showErrorVideoPlayerError: .webViewError
        case .showErrorInvalidArgument: .invalidConfiguration
        case .showErrorNoConnection: .noConnection
        case .showErrorAlreadyShowing: .invalidLoadState
        case .showErrorInternalError: .internalError
        case .showErrorTimeout: .timeout
        @unknown default: .unspecified
        }
        
        return .init(adapterError: adapterError,
                     mediatedNetworkErrorCode: rawValue,
                     mediatedNetworkErrorMessage: message)
    }
}

extension UADSBannerError
{
    var unityAdsAdapterError: MAAdapterError
    {
        let unityBannerErrorCode: UADSBannerErrorCode = .init(rawValue: code) ?? .codeUnknown
        
        let adapterError: MAAdapterError = switch unityBannerErrorCode
        {
        case .codeUnknown: .unspecified
        case .codeNativeError: .internalError
        case .codeWebViewError: .webViewError
        case .codeNoFillError: .noFill
        case .initializeFailed: .notInitialized
        case .invalidArgument: .invalidConfiguration
        @unknown default: .unspecified
        }
        
        return .init(adapterError: adapterError,
                     mediatedNetworkErrorCode: code,
                     mediatedNetworkErrorMessage: localizedDescription)
    }
}
