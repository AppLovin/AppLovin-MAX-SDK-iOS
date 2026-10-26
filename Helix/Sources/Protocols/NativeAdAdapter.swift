import AppLovinSDK
import Foundation
import VoodooAdn

protocol NativeAdAdapter {
    func loadAd(for parameters: any MAAdapterResponseParameters,
                eventsHandler: @escaping (AdnSdk.NativeAdUnit) -> Void,
                completionHandler: @escaping (Result<MANativeAd, MAAdapterError>) -> Void)
}
