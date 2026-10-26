import Foundation
import VoodooAdn

struct FullScreenAdServiceBase: FullScreenAdService {
    private let placement: AdnSdk.Placement

    init(placement: AdnSdk.Placement) {
        self.placement = placement
    }

    func loadAd(_ options: AdServiceLoadOptions, completion: @escaping (Result<any AdnSdk.AdUnit, any Error>) -> Void) {
        AdnSdk.loadFullScreenAd(.init(placement: placement, adMarkup: options.adMarkup, configuration: nil)) { result in
            completion(result)
        }
    }
}
