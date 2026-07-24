import AppLovinSDK
import Foundation
import VoodooAdn

// swiftlint:disable file_types_order
public extension AdnSdk {
    /// Represents the AppLovin Adn adapater.
    @objc(ALVoodooAdapter)
    final class AppLovinAdapter: ALMediationAdapter {
        private var servicesProvider: ServicesProvider = ServicesProviderBase()

        private var signalProvider: MASignalProvider {
            servicesProvider.signalProvider
        }

        private lazy var interstitialAdAdapter: FullscreenAdAdapter = FullscreenAdAdapterBase(
            adStorage: .init(queue: .init(label: "AdnSdk.AppLovin.InterstitialAdStorage")),
            adService: servicesProvider.interstitialAdService
        )
        private lazy var rewardedAdAdapter: FullscreenAdAdapter = FullscreenAdAdapterBase(
            adStorage: .init(queue: .init(label: "AdnSdk.AppLovin.RewardedAdStorage")),
            adService: servicesProvider.rewardedAdService
        )
        private lazy var nativeAdAdapter: NativeAdAdapter = NativeAdAdapterBase(
            adService: servicesProvider.nativeAdService
        )
    }
}

// ALMediationAdapter overrides
public extension AdnSdk.AppLovinAdapter {
    /// Version of the mediated network SDK.
    override var sdkVersion: String {
        AdnSdk.version
    }

    /// Version of the AppLovin Adn adapter.
    override var adapterVersion: String {
        Constants.adapterVersion
    }

    /// Main constructor.
    override func initialize(with parameters: any MAAdapterInitializationParameters) async -> (MAAdapterInitializationStatus, String?) {
        log(lifecycleEvent: .initializing())
        do {
            try await AdnSdk.initialize(options: .withMediationName(Constants.mediationName))
            log(lifecycleEvent: .initializeSuccess())
            return (.initializedSuccess, nil)
        } catch {
            log(lifecycleEvent: .initializeFailure(description: error.localizedDescription))
            return (.initializedFailure, error.localizedDescription)
        }
    }
}

extension AdnSdk.AppLovinAdapter: MASignalProvider {
    public func collectSignal(with parameters: any MASignalCollectionParameters, andNotify delegate: any MASignalCollectionDelegate) {
        log(signalEvent: .collecting)
        signalProvider.collectSignal(with: parameters,
                                     andNotify: SignalCollectionLoggingDelegate(adapter: self, original: delegate))
    }
}

extension AdnSdk.AppLovinAdapter: MAInterstitialAdapter {
    public func loadInterstitialAd(for parameters: any MAAdapterResponseParameters, andNotify delegate: any MAInterstitialAdapterDelegate) {
        log(adEvent: .loading(), id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
        let bridge = MAInterstitialAdapterDelegateBridge(adapter: self, original: delegate)
        interstitialAdAdapter.loadAd(for: parameters) { result in
            bridge.handleLoadAdResult(result)
        }
    }

    public func showInterstitialAd(for parameters: any MAAdapterResponseParameters, andNotify delegate: any MAInterstitialAdapterDelegate) {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .interstitial)
        let bridge = MAInterstitialAdapterDelegateBridge(adapter: self, original: delegate)
        interstitialAdAdapter.showAd(for: parameters) { result in
            bridge.handleShowAdResult(result)
        }
    }
}

extension AdnSdk.AppLovinAdapter: MARewardedAdapter {
    public func loadRewardedAd(for parameters: any MAAdapterResponseParameters, andNotify delegate: any MARewardedAdapterDelegate) {
        log(adEvent: .loading(), id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
        let bridge = MARewardedAdapterDelegateBridge(adapter: self,
                                                     original: delegate,
                                                     reward: reward,
                                                     shouldAlwaysRewardUser: shouldAlwaysRewardUser)
        rewardedAdAdapter.loadAd(for: parameters) { result in
            bridge.handleLoadAdResult(result)
        }
    }

    public func showRewardedAd(for parameters: any MAAdapterResponseParameters, andNotify delegate: any MARewardedAdapterDelegate) {
        log(adEvent: .showing, id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .rewarded)
        configureReward(for: parameters)
        let bridge = MARewardedAdapterDelegateBridge(adapter: self,
                                                     original: delegate,
                                                     reward: reward,
                                                     shouldAlwaysRewardUser: shouldAlwaysRewardUser)
        rewardedAdAdapter.showAd(for: parameters) { result in
            bridge.handleShowAdResult(result)
        }
    }
}

extension AdnSdk.AppLovinAdapter: MANativeAdAdapter {
    public func loadNativeAd(for parameters: any MAAdapterResponseParameters, andNotify delegate: any MANativeAdAdapterDelegate) {
        log(adEvent: .loading(), id: parameters.thirdPartyAdPlacementIdentifier, adFormat: .native)
        let bridge = MANativeAdAdapterDelegateBridge(adapter: self, original: delegate)
        nativeAdAdapter.loadAd(for: parameters,
                               eventsHandler: bridge.handleAdEvents,
                               completionHandler: bridge.handleLoadAdResult)
    }
}

/// Wraps the MAX signal collection delegate to log the outcome, following the MAX adapter logging convention.
private final class SignalCollectionLoggingDelegate: NSObject, MASignalCollectionDelegate {
    private weak var adapter: ALMediationAdapter?
    private let original: any MASignalCollectionDelegate

    init(adapter: ALMediationAdapter?, original: any MASignalCollectionDelegate) {
        self.adapter = adapter
        self.original = original
    }

    func didCollectSignal(_ signal: String?) {
        adapter?.log(signalEvent: .collectionSuccess)
        original.didCollectSignal(signal)
    }

    func didFailToCollectSignalWithErrorMessage(_ errorMessage: String?) {
        adapter?.log(signalEvent: .collectionFailed(description: errorMessage))
        original.didFailToCollectSignalWithErrorMessage(errorMessage)
    }
}
