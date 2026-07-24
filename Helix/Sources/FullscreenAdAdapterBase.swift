import AppLovinSDK
import Foundation
import VoodooAdn

class FullscreenAdAdapterBase {
    private var adStorage: AdUnitStorage
    private let adService: FullScreenAdService

    init(adStorage: AdUnitStorage, adService: FullScreenAdService) {
        self.adStorage = adStorage
        self.adService = adService
    }
}

extension FullscreenAdAdapterBase: FullscreenAdAdapter {
    func loadAd(for parameters: any MAAdapterResponseParameters, completionHandler: @escaping (MAAdapterErrorResult) -> Void) {

        let identifier = parameters.thirdPartyAdPlacementIdentifier
        adStorage.removeAdUnitWithIdentifier(identifier)

        adService.loadAd(.init(adMarkup: parameters.bidResponse, thirdPartyAdPlacementIdentifier: identifier)) { [weak self] result in
            self?.handleLoadAd(identifier, from: result, completionHandler: completionHandler)
        }
    }

    func showAd(for parameters: any MAAdapterResponseParameters, eventHandler: @escaping (AdUnitShowStateResult) -> Void) {
        // We must ensure that the ad is not expired and can be displayed, else return an error.

        let identifier = parameters.thirdPartyAdPlacementIdentifier
        guard let adUnit = adStorage.adUnitWithIdentifier(identifier) else {
            eventHandler(.failure(error: MAAdapterError.adDisplay("No ad found to display")))
            return
        }

        adUnit.show(with: .init(viewController: parameters.viewController()), events: eventHandler)
    }

    private func handleLoadAd(_ identifier: String,
                              from result: Result<AdnSdk.AdUnit, Error>,
                              completionHandler: @escaping (MAAdapterErrorResult) -> Void) {
        switch result {
        case .success(let adUnit):
            adStorage.save(adUnit: adUnit, withIdentifier: identifier)
            completionHandler(.success(()))

        case .failure(let error):
            completionHandler(.failure(error.adapterLoadAdError))
        }
    }
}

private extension MAAdapterResponseParameters {
    func viewController() -> UIViewController {
        guard ALSdk.versionCode >= Constants.minimumSdkVersion else {
            return ALUtils.topViewControllerFromKeyWindow()
        }
        return presentingViewController ?? ALUtils.topViewControllerFromKeyWindow()
    }
}
