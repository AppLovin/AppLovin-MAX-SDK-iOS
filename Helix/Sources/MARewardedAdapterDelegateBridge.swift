import AppLovinSDK
import Foundation

final class MARewardedAdapterDelegateBridge {
    weak var original: MARewardedAdapterDelegate?
    var shouldAlwaysRewardUser: Bool
    var reward: MAReward?
    private var hasBeenRewarded = false
    private weak var adapter: ALMediationAdapter?
    private let adFormat: MAAdFormat = .rewarded

    init(adapter: ALMediationAdapter? = nil,
         original: MARewardedAdapterDelegate? = nil,
         reward: MAReward? = nil,
         shouldAlwaysRewardUser: Bool = false) {
        self.adapter = adapter
        self.original = original
        self.shouldAlwaysRewardUser = shouldAlwaysRewardUser
        self.reward = reward
    }

    func handleLoadAdResult(_ result: MAAdapterErrorResult) {
        switch result {
        case .success:
            adapter?.log(adEvent: .loaded, adFormat: adFormat)
            original?.didLoadRewardedAd()

        case .failure(let error):
            adapter?.log(adEvent: .loadFailed(error: error), adFormat: adFormat)
            original?.didFailToLoadRewardedAdWithError(error)
        }
    }

    func handleShowAdResult(_ result: AdUnitShowStateResult) {
        switch result {
        case .click:
            adapter?.log(adEvent: .clicked, adFormat: adFormat)
            original?.didClickRewardedAd()

        case .impression:
            adapter?.log(adEvent: .displayed, adFormat: adFormat)
            original?.didDisplayRewardedAd()

        case .dismissed:
            if shouldAlwaysRewardUser {
                rewardUser()
            }
            adapter?.log(adEvent: .hidden, adFormat: adFormat)
            original?.didHideRewardedAd()

        case .rewarded:
            rewardUser()

        case .failure(let error):
            let displayError = error.adapterDisplayAdError
            adapter?.log(adEvent: .displayFailed(error: displayError), adFormat: adFormat)
            original?.didFailToDisplayRewardedAdWithError(displayError)
        
        case .started:
            // do nothing since mediation doesn't distinct impression vs displayed ad.
            return
            
        
        @unknown default:
            return
        }
    }

    private func rewardUser() {
        guard let reward, !hasBeenRewarded else {
            return
        }
        hasBeenRewarded = true
        adapter?.log(adEvent: .userRewarded(reward: reward), adFormat: adFormat)
        original?.didRewardUser(with: reward)
    }
}
