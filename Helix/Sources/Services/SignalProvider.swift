import AppLovinSDK
import Foundation
import VoodooAdn

class SignalProvider: NSObject, MASignalProvider {
    private var privacyService: PrivacyService

    init(privacyService: PrivacyService) {
        self.privacyService = privacyService
    }

    func collectSignal(with parameters: any MASignalCollectionParameters, andNotify delegate: any MASignalCollectionDelegate) {
        privacyService.updatePrivacySettings(parameters)
        AdnSdk.getToken(adType: parameters.adFormat.label) { token in
            delegate.didCollectSignal(token)
        }
    }
}

private extension MAAdFormat {
    var adnFormat: AdnSdk.Placement {
        switch self {
        case .interstitial:
                .interstitial

        case .rewarded:
                .rewarded

        case .native:
                .native

        default:
                .unknown
        }
    }
}
