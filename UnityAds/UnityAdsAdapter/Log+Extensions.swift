//
//  Log+Extensions.swift
//  UnityAdsAdapter
//
//  Created by Vedant Mehta on 4/10/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK

extension LogEvent
{
    enum UnityAds
    {
        case userLeftApplication
    }
}

extension AdapterDelegate
{
    func log(customEvent: LogEvent.UnityAds)
    {
        switch customEvent
        {
        case .userLeftApplication:
            adapter.logInfo("\(adFormat) ad placement \"\(adIdentifier)\" left application")
        }
    }
}
