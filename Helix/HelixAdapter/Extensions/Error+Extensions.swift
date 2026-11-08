//
//  Error+Extensions.swift
//  HelixAdapter
//
//  Created by Nana Amoah on 9/25/26.
//  Copyright © 2026 AppLovin. All rights reserved.
//

import AppLovinSDK

extension Error
{
    var helixLoadAdapterError: MAAdapterError
    {
        .init(adapterError: .serverError,
              mediatedNetworkErrorCode: code,
              mediatedNetworkErrorMessage: localizedDescription)
    }
    
    var helixDisplayAdapterError: MAAdapterError
    {
        .init(adapterError: .adDisplayFailedError,
              mediatedNetworkErrorCode: code,
              mediatedNetworkErrorMessage: localizedDescription)
    }
}
