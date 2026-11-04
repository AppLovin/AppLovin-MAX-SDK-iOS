import Foundation
import VoodooAdn

protocol FullScreenAdService {
    func loadAd(_ options: AdServiceLoadOptions, completion: @escaping (Result<AdnSdk.AdUnit, Error>) -> Void)
}
