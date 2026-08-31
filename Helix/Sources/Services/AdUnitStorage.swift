import Foundation
import VoodooAdn

final class AdUnitStorage: AdUnitReader, AdUnitSaver {
    private var storage: [String: AdnSdk.AdUnit] = [:]
    private let syncQueue: DispatchQueue

    init(queue: DispatchQueue) {
        self.syncQueue = queue
    }

    func adUnitWithIdentifier(_ identifier: String) -> AdnSdk.AdUnit? {
        syncQueue.sync {
            storage[identifier]
        }
    }

    func save(adUnit: any AdnSdk.AdUnit, withIdentifier identifier: String) {
        syncQueue.sync {
            storage[identifier] = adUnit
        }
    }

    func removeAdUnitWithIdentifier(_ identifier: String) {
        _ = syncQueue.sync {
            storage.removeValue(forKey: identifier)
        }
    }

    func removeAll() {
        syncQueue.sync {
            storage.removeAll()
        }
    }
}
