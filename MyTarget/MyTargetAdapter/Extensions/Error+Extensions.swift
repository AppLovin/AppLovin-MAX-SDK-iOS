//
//  Error+Extensions.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 10/13/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK

extension Error
{
    var myTargetAdapterError: MAAdapterError
    {
        MAAdapterError(adapterError: .noFill,
                       mediatedNetworkErrorCode: code,
                       mediatedNetworkErrorMessage: localizedDescription)
    }
}
