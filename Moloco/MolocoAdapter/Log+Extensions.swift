//
//  Log+Extensions.swift
//  MolocoAdapter
//
//  Created by Alan Cao on 7/1/24.
//  Copyright © 2024 AppLovin. All rights reserved.
//

import AppLovinSDK

extension LogEvent
{
    enum Moloco
    {
        case unsupportedMinimumOS
    }
}

@available(iOS 13.0, *)
extension MolocoAdapter
{
    func log(customEvent: LogEvent.Moloco)
    {
        switch customEvent
        {
        case .unsupportedMinimumOS:
            logInfo("Current iOS version is: \(UIDevice.current.systemVersion), but Moloco requires minimum iOS 13.0")
        }
    }
}
