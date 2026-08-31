import Foundation
import VoodooAdn

protocol NativeAdService {
    func loadAd(_ options: AdServiceLoadOptions, completion: @escaping (Result<AdnSdk.NativeAdUnit, Error>) -> Void)
}
