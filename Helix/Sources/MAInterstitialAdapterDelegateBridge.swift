import AppLovinSDK
import Foundation

final class MAInterstitialAdapterDelegateBridge {
    weak var original: MAInterstitialAdapterDelegate?
    private weak var adapter: ALMediationAdapter?
    private let adFormat: MAAdFormat = .interstitial

    init(adapter: ALMediationAdapter? = nil, original: MAInterstitialAdapterDelegate? = nil) {
        self.adapter = adapter
        self.original = original
    }

    func handleLoadAdResult(_ result: MAAdapterErrorResult) {
        switch result {
        case .success:
            adapter?.log(adEvent: .loaded, adFormat: adFormat)
            original?.didLoadInterstitialAd()

        case .failure(let error):
            adapter?.log(adEvent: .loadFailed(error: error), adFormat: adFormat)
            original?.didFailToLoadInterstitialAdWithError(error)
        }
    }

    func handleShowAdResult(_ result: AdUnitShowStateResult) {
        switch result {
        case .click:
            adapter?.log(adEvent: .clicked, adFormat: adFormat)
            original?.didClickInterstitialAd()

        case .impression:
            adapter?.log(adEvent: .displayed, adFormat: adFormat)
            original?.didDisplayInterstitialAd()

        case .dismissed:
            adapter?.log(adEvent: .hidden, adFormat: adFormat)
            original?.didHideInterstitialAd()

        case .rewarded:
            return

        case .failure(let error):
            let displayError = error.adapterDisplayAdError
            adapter?.log(adEvent: .displayFailed(error: displayError), adFormat: adFormat)
            original?.didFailToDisplayInterstitialAdWithError(displayError)

        case .started:
            return
            // do nothing since mediation doesn't distinct impression vs displayed ad.

        @unknown default:
            return
        }
    }
}
