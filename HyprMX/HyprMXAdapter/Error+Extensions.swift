//
//  Error+Extensions.swift
//  HyprMXAdapter
//
//  Created by Chris Cong on 10/13/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK
import HyprMX

extension Error
{
    var hyprMXAdapterError: MAAdapterError
    {
        let adapterError: MAAdapterError
        switch HyprMXError(UInt32(code))
        {
        case NO_FILL:
            adapterError = .noFill
        case DISPLAY_ERROR:
            adapterError = .internalError
        case AD_SIZE_NOT_SET, PLACEMENT_DOES_NOT_EXIST, PLACEMENT_NAME_NOT_SET:
            adapterError = .invalidConfiguration
        case SDK_NOT_INITIALIZED:
            adapterError = .notInitialized
        default:
            adapterError = .unspecified
        }
        
        return MAAdapterError(adapterError: adapterError,
                              mediatedNetworkErrorCode: code,
                              mediatedNetworkErrorMessage: localizedDescription)
    }
}
