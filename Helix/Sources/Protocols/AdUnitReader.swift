import Foundation
import VoodooAdn

protocol AdUnitReader {
    func adUnitWithIdentifier(_ identifier: String) -> AdnSdk.AdUnit?
}
