import AppLovinSDK
import Foundation
import VoodooAdn

final class ServicesProviderBase: ServicesProvider {
    var privacyService: PrivacyService {
        PrivacyServiceBase()
    }

    var signalProvider: MASignalProvider {
        SignalProvider(privacyService: privacyService)
    }

    let interstitialAdService: FullScreenAdService = FullScreenAdServiceBase(placement: .interstitial)
    let rewardedAdService: FullScreenAdService = FullScreenAdServiceBase(placement: .rewarded)
    let nativeAdService: NativeAdService = NativeAdServiceBase()
}
