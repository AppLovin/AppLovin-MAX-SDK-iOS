import AppLovinSDK
import Foundation
import VoodooAdn

struct PrivacyServiceBase: PrivacyService {
    func updatePrivacySettings(_ settings: MAAdapterParameters) {
        updateUserConsent(settings)
    }

    private func updateUserConsent(_ settings: MAAdapterParameters) {
    
        if let consent = settings.userConsent {
            AdnSdk.setUserGDPRConsent(consent.boolValue)
        }
        
        if let doNotSell = settings.doNotSell {
            AdnSdk.setDoNotSell(doNotSell.boolValue)
        }
        
    }
}
