//
//  Log+Extensions.swift
//  MyTargetAdapter
//
//  Created by Ritam Sarmah on 10/13/23.
//  Copyright © 2023 AppLovin. All rights reserved.
//

import AppLovinSDK

extension LogEvent
{
    enum MyTarget
    {
        case userLeftApplication
    }
}

extension AdapterDelegate
{
    func log(customEvent: LogEvent.MyTarget)
    {
        switch customEvent
        {
        case .userLeftApplication:
            adapter.logInfo("\(adFormat) ad user left application (\(adIdentifier))")
        }
    }
}
