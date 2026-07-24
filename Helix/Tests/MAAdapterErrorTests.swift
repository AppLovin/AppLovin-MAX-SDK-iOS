@testable import VoodooMaxAdapter
import XCTest
import XCTestToolKit

final class MAAdapterErrorTests: XCTestCase {
    func test_ad_display_error_with_string() {
        let error = MAAdapterError.adDisplay("test error")
    }
}
