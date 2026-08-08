import AppLovinSDK
import Foundation
import VoodooAdn

class NativeAdAdapterBase {
    private let adService: NativeAdService

    init(adService: NativeAdService) {
        self.adService = adService
    }
}

extension NativeAdAdapterBase: NativeAdAdapter {
    func loadAd(for parameters: any MAAdapterResponseParameters,
                eventsHandler: @escaping (AdnSdk.NativeAdUnit) -> Void,
                completionHandler: @escaping (Result<MANativeAd, MAAdapterError>) -> Void) {

        adService.loadAd(.init(adMarkup: parameters.bidResponse,
                               thirdPartyAdPlacementIdentifier: parameters.thirdPartyAdPlacementIdentifier)) { [weak self] result in
            self?.handleLoadAd(result, eventsHandler: eventsHandler, completionHandler: completionHandler)
        }
    }

    private func handleLoadAd(_ result: Result<AdnSdk.NativeAdUnit, Error>,
                              eventsHandler: @escaping (AdnSdk.NativeAdUnit) -> Void,
                              completionHandler: @escaping (Result<MANativeAd, MAAdapterError>) -> Void) {
        switch result {
        case .success(let adUnit):
            eventsHandler(adUnit)
            Task { @MainActor in
                completionHandler(.success(adUnit.MANativeAd))
            }

        case .failure(let error):
            completionHandler(.failure(error.adapterLoadAdError))
        }
    }
}

extension AdnSdk.NativeAdUnit {
    // swiftlint:disable closure_body_length
    @MainActor var MANativeAd: ADNMANativeAd {
        .init(container: self, format: .native) { builder in
            builder.title = getRawData(of: .title)
            builder.advertiser = getRawData(of: .advertiser)
            builder.body = getRawData(of: .body)
            builder.callToAction = getRawData(of: .cta)
            builder.starRating = getRawData(of: .starRating)
            builder.mediaView = getUIView(of: .mainVideo) ?? getUIView(of: .mainImage)
            builder.iconView = getUIView(of: .icon)
            builder.icon = getRawData(of: .icon).flatMap { try? Data(contentsOf: $0) }
                                                .flatMap { UIImage(data: $0)}
                                                .map { .init(image: $0)}
     
            builder.mediaContentAspectRatio = aspectRatio
            
            
            builder.optionsView = getUIView(of: .privacy)
        }
    }
    // swiftlint:enable closure_body_length
}
