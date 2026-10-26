import AppLovinSDK
import Foundation

extension MAAdapterError: Swift.Error {
    static func adDisplay(_ errorString: String) -> MAAdapterError {
        MAAdapterError(code: Constants.adDisplayErrorCode, errorString: errorString)
    }

    static func adDisplay(_ error: Error) -> MAAdapterError {
        MAAdapterError(code: Constants.adDisplayErrorCode,
                       errorString: "Ad Display Failed",
                       mediatedNetworkErrorCode: error.code,
                       mediatedNetworkErrorMessage: error.localizedDescription)
    }
}
