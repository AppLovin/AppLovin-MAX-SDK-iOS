import AppLovinSDK
import Foundation
import VoodooAdn

typealias MAAdapterErrorResult = Result<Void, MAAdapterError>
typealias AdUnitShowStateResult = AdnSdk.AdFullscreenShowState

protocol FullscreenAdAdapter {
    func loadAd(for parameters: any MAAdapterResponseParameters, completionHandler: @escaping (MAAdapterErrorResult) -> Void)
    func showAd(for parameters: any MAAdapterResponseParameters, eventHandler: @escaping (AdUnitShowStateResult) -> Void)
}
