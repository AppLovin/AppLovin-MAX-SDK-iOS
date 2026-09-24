import AppLovinSDK
import Foundation
import VoodooAdn

final class MANativeAdAdapterDelegateBridge {
    weak var original: MANativeAdAdapterDelegate?
    private weak var adapter: ALMediationAdapter?
    private let adFormat: MAAdFormat = .native

    init(adapter: ALMediationAdapter? = nil, original: MANativeAdAdapterDelegate? = nil) {
        self.adapter = adapter
        self.original = original
    }

    func handleLoadAdResult(_ result: Result<MANativeAd, MAAdapterError>) {
        switch result {
        case .success(let ad):
            adapter?.log(adEvent: .loaded, adFormat: adFormat)
            original?.didLoadAd(for: ad, withExtraInfo: nil)

        case .failure(let error):
            adapter?.log(adEvent: .loadFailed(error: error), adFormat: adFormat)
            original?.didFailToLoadNativeAdWithError(error)
        }
    }

    func handleAdEvents(_ adUnit: AdnSdk.NativeAdUnit) {
        adUnit.observeShowEvents { event in
            self.handleShowEvent(event)
        }
    }

    private func handleShowEvent(_ event: AdnSdk.AdNativeShowState) {
        switch event {
        case .click:
            adapter?.log(adEvent: .clicked, adFormat: adFormat)
            original?.didClickNativeAd()

        case .impression:
            adapter?.log(adEvent: .displayed, adFormat: adFormat)
            original?.didDisplayNativeAd(withExtraInfo: nil)

        case .started:
            return
            // do nothing since mediation doesn't distinct impression vs displayed ad.

        default:
            break
        }
    }
}
