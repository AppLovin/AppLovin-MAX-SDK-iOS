import Foundation
import VoodooAdn

protocol AdUnitSaver {
    func save(adUnit: AdnSdk.AdUnit, withIdentifier identifier: String)
    func removeAdUnitWithIdentifier(_ identifier: String)
    func removeAll()
}
