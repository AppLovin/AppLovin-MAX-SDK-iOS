import AppLovinSDK
import Foundation
import VoodooAdn
import UIKit

final class ADNMANativeAd: MANativeAd {
    private let container: AdnSdk.NativeAdUnit
    private var gestureRecognizers = [UITapGestureRecognizer]()

    init(container: AdnSdk.NativeAdUnit, format: MAAdFormat, builderBlock: (MANativeAdBuilder) -> Void) {
        self.container = container
        super.init(format: format, builderBlock: builderBlock)
    }
    
    deinit {
        gestureRecognizers.forEach { $0.view?.removeGestureRecognizer($0) }
    }

    override func prepare(forInteractionClickableViews clickableViews: [UIView], withContainer _: UIView) -> Bool {
        clickableViews.forEach { view in
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didClick))
            view.addGestureRecognizer(gestureRecognizer)
            gestureRecognizers.append(gestureRecognizer)
        }
        return true
    }

    @objc
    private func didClick() {
        container.click()
    }
}
