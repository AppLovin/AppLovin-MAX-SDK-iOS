import AppLovinSDK
import Foundation

protocol ServicesProvider {
    var privacyService: PrivacyService { get }
    var signalProvider: MASignalProvider { get }
    var interstitialAdService: FullScreenAdService { get }
    var rewardedAdService: FullScreenAdService { get }
    var nativeAdService: NativeAdService { get }
}
