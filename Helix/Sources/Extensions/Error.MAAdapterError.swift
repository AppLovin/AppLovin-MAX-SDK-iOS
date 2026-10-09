import AppLovinSDK
import Foundation

extension Error {
    var adapterDisplayAdError: MAAdapterError {
        guard let self = self as? MAAdapterError else {
            return MAAdapterError.adDisplay(self)
        }

        return self
    }

    var adapterLoadAdError: MAAdapterError {
        MAAdapterError(adapterError: .serverError,
                       mediatedNetworkErrorCode: -1,
                       mediatedNetworkErrorMessage: localizedDescription)
    }
}
