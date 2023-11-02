//
//  ALIronSourceMediationAdapter.m
//  AppLovinSDK
//
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALIronSourceMediationAdapter.h"
#import <IronSource/IronSource.h>

#define ADAPTER_VERSION @"7.5.1.0.0"

@interface ALIronSourceMediationAdapterRouter : ALMediationAdapterRouter <ISDemandOnlyInterstitialDelegate, ISDemandOnlyRewardedVideoDelegate, ISLogDelegate>
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
+ (NSString *)interstitialRouterIdentifierForInstanceID:(NSString *)instanceID;
+ (NSString *)rewardedVideoRouterIdentifierForInstanceID:(NSString *)instanceID;
@end

@interface ALIronSourceMediationAdapterAdViewDelegate : NSObject <ISDemandOnlyBannerDelegate>
@property (nonatomic,   weak) ALIronSourceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALIronSourceMediationAdapter ()
@property (nonatomic, strong, readonly) ALIronSourceMediationAdapterRouter *router;
@property (nonatomic, copy) NSString *routerPlacementIdentifier;

@property (nonatomic, strong) ALIronSourceMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@end

@implementation ALIronSourceMediationAdapter
@dynamic router;

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *appKey = [parameters.serverParameters al_stringForKey: @"app_key"];
        [self log: @"Initializing IronSource SDK with app key: %@...", appKey];
        
        if ( [parameters isTesting] )
        {
            [IronSource setAdaptersDebug: YES];
            [IronSource setLogDelegate: self.router];
        }
        
        if ( [parameters.serverParameters al_numberForKey: @"set_mediation_identifier"].boolValue )
        {
            [IronSource setMediationType: self.mediationTag];
        }
        
        [self setPrivacySettingsWithParameters: parameters];
        
        NSNumber *isDoNotSell = [parameters isDoNotSell];
        if ( isDoNotSell != nil )
        {
            // NOTE: `setMetaData` must be called _before_ initializing their SDK
            [IronSource setMetaDataWithKey: @"do_not_sell" value: isDoNotSell.boolValue ? @"YES" : @"NO"];
        }
        
        NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
        if ( isAgeRestrictedUser != nil )
        {
            [IronSource setMetaDataWithKey: @"is_child_directed" value: isAgeRestrictedUser.boolValue ? @"YES" : @"NO"];
        }
        
        [self updateIronSourceDelegates];
        
        [IronSource initISDemandOnly: appKey adUnits: [self adFormatsToInitializeFromParameters: parameters]];
    });
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [IronSource sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    [self.router removeAdapter: self forPlacementIdentifier: self.routerPlacementIdentifier];
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self setPrivacySettingsWithParameters: parameters];
    
    NSString *signal = [IronSource getISDemandOnlyBiddingData];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading ironSource %@interstitial for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    [self updateIronSourceDelegates];
    [self setPrivacySettingsWithParameters: parameters];
    
    // Create a format specific router identifier to ensure that the router can distinguish between them.
    self.routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceID];
    [self.router addInterstitialAdapter: self
                               delegate: delegate
                 forPlacementIdentifier: self.routerPlacementIdentifier];
    
    if ( isBiddingAd )
    {
        [IronSource loadISDemandOnlyInterstitialWithAdm: instanceID adm: bidResponse];
    }
    else
    {
        if ( [IronSource hasISDemandOnlyInterstitial: instanceID] )
        {
            [self log: @"Ad is available already for instance ID: %@", instanceID];
            [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifier];
        }
        else
        {
            [IronSource loadISDemandOnlyInterstitial: instanceID];
        }
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing ironSource interstitial for instance ID: %@", instanceID];
    
    [self updateIronSourceDelegates];
    [self.router addShowingAdapter: self];
    
    if ( [IronSource hasISDemandOnlyInterstitial: instanceID] )
    {
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [IronSource showISDemandOnlyInterstitial: presentingViewController instanceId: instanceID];
    }
    else
    {
        [self log: @"Unable to show ironSource interstitial - no ad loaded for instance ID: %@", instanceID];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.router didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceID]
                                                        error: [MAAdapterError errorWithCode: -4205
                                                                                 errorString: @"Ad Display Failed"
                                                                      thirdPartySdkErrorCode: 0
                                                                   thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading ironSource %@rewarded for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    [self updateIronSourceDelegates];
    [self setPrivacySettingsWithParameters: parameters];
    
    // Create a format specific router identifier to ensure that the router can distinguish between them.
    self.routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceID];
    [self.router addRewardedAdapter: self delegate: delegate forPlacementIdentifier: self.routerPlacementIdentifier];
    
    if ( isBiddingAd )
    {
        [IronSource loadISDemandOnlyRewardedVideoWithAdm: instanceID adm: bidResponse];
    }
    else
    {
        if ( [IronSource hasISDemandOnlyRewardedVideo: instanceID] )
        {
            [self log: @"Ad is available already for instance ID: %@", instanceID];
            [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifier];
        }
        else
        {
            [IronSource loadISDemandOnlyRewardedVideo: instanceID];
        }
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing ironSource rewarded for instance ID: %@", instanceID];
    
    [self updateIronSourceDelegates];
    [self.router addShowingAdapter: self];
    
    if ( [IronSource hasISDemandOnlyRewardedVideo: instanceID] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController;
        if ( ALSdk.versionCode >= 11020199 )
        {
            presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        }
        else
        {
            presentingViewController = [ALUtils topViewControllerFromKeyWindow];
        }
        
        [IronSource showISDemandOnlyRewardedVideo: presentingViewController instanceId: instanceID];
    }
    else
    {
        [self log: @"Unable to show ironSource rewarded - no ad loaded for instance ID: %@", instanceID];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.router didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceID]
                                                        error: [MAAdapterError errorWithCode: -4205
                                                                                 errorString: @"Ad Display Failed"
                                                                      thirdPartySdkErrorCode: 0
                                                                   thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading %@%@ ad for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), adFormat.label, instanceID];
    
    self.adViewAdapterDelegate = [[ALIronSourceMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [IronSource setISDemandOnlyBannerDelegate: self.adViewAdapterDelegate forInstanceId: instanceID];
    
    [self setPrivacySettingsWithParameters: parameters];
    
    __block UIViewController *presentingViewController;
    dispatchSyncOnMainQueue(^{
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    });
    
    if ( isBiddingAd )
    {
        [IronSource loadISDemandOnlyBannerWithAdm: bidResponse
                                       instanceId: instanceID
                                   viewController: presentingViewController
                                             size: [self toISBannerSize: adFormat]];
    }
    else
    {
        [IronSource loadISDemandOnlyBannerWithInstanceId: instanceID
                                          viewController: presentingViewController
                                                    size: [self toISBannerSize: adFormat]];
    }
}

#pragma mark - Dynamic Properties

- (ALIronSourceMediationAdapterRouter *)router
{
    return [ALIronSourceMediationAdapterRouter sharedInstance];
}

#pragma mark - Utility Methods

- (void)updateIronSourceDelegates
{
    [IronSource setISDemandOnlyInterstitialDelegate: self.router];
    [IronSource setISDemandOnlyRewardedVideoDelegate: self.router];
}

- (void)setPrivacySettingsWithParameters:(id<MAAdapterParameters>)parameters
{
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [IronSource setConsent: hasUserConsent.boolValue];
    }
}

- (NSArray<NSString *> *)adFormatsToInitializeFromParameters:(id<MAAdapterInitializationParameters>)parameters
{
    NSArray<NSString *> *adFormats = [parameters.serverParameters al_arrayForKey: @"init_ad_formats"];
    if ( adFormats.count == 0 )
    {
        // Default to initialize all ad formats if backend doesn't send down which ones to initialize
        return @[IS_INTERSTITIAL, IS_REWARDED_VIDEO, IS_BANNER];
    }
    
    NSMutableArray<NSString *> *adFormatsToInitialize = [NSMutableArray array];
    if ( [adFormats containsObject: @"inter"] )
    {
        [adFormatsToInitialize addObject: IS_INTERSTITIAL];
    }
    
    if ( [adFormats containsObject: @"rewarded"] )
    {
        [adFormatsToInitialize addObject: IS_REWARDED_VIDEO];
    }
    
    if ( [adFormats containsObject: @"banner"] )
    {
        [adFormatsToInitialize addObject: IS_BANNER];
    }
    
    return adFormatsToInitialize;
}

- (ISBannerSize *)toISBannerSize:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return ISBannerSize_BANNER;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return ISBannerSize_LARGE; // Note: LARGE is 320x90 - leaders weren't supported at the time of implementation.
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return ISBannerSize_RECTANGLE;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return ISBannerSize_BANNER;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)ironSourceError
{
    NSInteger ironSourceErrorCode = ironSourceError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( ironSourceErrorCode )
    {
        case 501:
        case 505:
        case 506:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 508: // Init failure
            adapterError = MAAdapterError.notInitialized;
            break;
        case 509: // No ads to show (Show Fail)
            adapterError = MAAdapterError.noFill;
            break;
        case 510: // Server Response Failed (Load Fail)
            adapterError = MAAdapterError.serverError;
            break;
        case 520: // No Internet Connection (Show Fail)
            adapterError = MAAdapterError.noConnection;
            break;
        case 524: // Placement %@ reached it's capping limit (Show Fail)
        case 526: // Ad Unit reached it's daily cap per session (Show Fail)
            adapterError = MAAdapterError.adFrequencyCappedError;
            break;
        case 1055: // Load aborted due to timeout (Load Fail)
            adapterError = MAAdapterError.timeout;
            break;
        case 1023: // Show RV called when no available ads to show (Show Fail)
            adapterError = MAAdapterError.adNotReady;
            break;
        case 1036: // Interstitial already showing (Show Fail)
        case 1037: // Interstitial already loaded (Load Fail)
        case 1022: // RV already showing (Show Fail)
        case 1056: // RV already loaded (Load Fail)
            adapterError = MAAdapterError.invalidLoadState;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: ironSourceErrorCode
               thirdPartySdkErrorMessage: ironSourceError.localizedDescription];
#pragma clang diagnostic pop
}

@end

#pragma mark - IronSource AdView Delegate

@implementation ALIronSourceMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerDidLoad:(ISDemandOnlyBannerView *)bannerView instanceId:(NSString *)instanceId
{
    [self.parentAdapter log: @"AdView ad loaded for instance ID: %@", instanceId];
    [self.delegate didLoadAdForAdView: bannerView];
}

- (void)bannerDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId
{
    [self.parentAdapter log: @"AdView failed to load for instance ID: %@ with error: %@", instanceId, error];
    
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerDidShow:(NSString *)instanceId
{
    [self.parentAdapter log: @"AdView shown for instance ID: %@", instanceId];
    [self.delegate didDisplayAdViewAd];
}

- (void)didClickBanner:(NSString *)instanceId
{
    [self.parentAdapter log: @"AdView ad clicked for instance ID: %@", instanceId];
    [self.delegate didClickAdViewAd];
}

- (void)bannerWillLeaveApplication:(NSString *)instanceId
{
    [self.parentAdapter log: @"AdView ad left application for instance ID: %@", instanceId];
}

@end

@implementation ALIronSourceMediationAdapterRouter

#pragma mark - ISDemandOnlyInterstitialDelegate Methods

- (void)interstitialDidLoad:(NSString *)instanceId
{
    [self log: @"Interstitial loaded for instance ID: %@", instanceId];
    [self didLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]];
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId
{
    [self log: @"Interstitial failed to load for instance ID: %@ with error: %@", instanceId, error];
    [self didFailToLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]
                                          error: [ALIronSourceMediationAdapter toMaxError: error]];
}

- (void)interstitialDidOpen:(NSString *)instanceId
{
    [self log: @"Interstitial opened for instance ID: %@", instanceId];
    [self didDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]];
}

- (void)interstitialDidClose:(NSString *)instanceId
{
    [self log: @"Interstitial hidden for instance ID: %@", instanceId];
    [self didHideAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]];
}

- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId
{
    [self log: @"Interstitial failed to show for instance ID: %@ with error: %@", instanceId, error];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]
                                             error: [MAAdapterError errorWithCode: -4205
                                                                      errorString: @"Ad Display Failed"
                                                           thirdPartySdkErrorCode: error.code
                                                        thirdPartySdkErrorMessage: error.localizedDescription]];
#pragma clang diagnostic pop
}

- (void)didClickInterstitial:(NSString *)instanceId
{
    [self log: @"Interstitial clicked for instance ID: %@", instanceId];
    [self didClickAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]];
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate methods

- (void)rewardedVideoDidLoad:(NSString *)instanceId
{
    [self log: @"Rewarded ad loaded for instance ID: %@", instanceId];
    [self didLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]];
}

- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId
{
    [self log: @"Rewarded ad failed to load for instance ID: %@", instanceId];
    [self didFailToLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]
                                          error: [ALIronSourceMediationAdapter toMaxError: error]];
}

- (void)rewardedVideoDidOpen:(NSString *)instanceId
{
    [self log: @"Rewarded ad shown for instance ID: %@", instanceId];
    [self didDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]];
    [self didStartRewardedVideoForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]];
}

- (void)rewardedVideoDidClose:(NSString *)instanceId
{
    NSString *routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId];
    [self didCompleteRewardedVideoForPlacementIdentifier: routerPlacementIdentifier];
    
    if ( [self hasGrantedReward] || [self shouldAlwaysRewardUserForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]] )
    {
        MAReward *reward = [self rewardForPlacementIdentifier: routerPlacementIdentifier];
        [self log: @"Rewarded ad rewarded user with reward: %@ for instance ID: %@", reward, instanceId];
        [self didRewardUserForPlacementIdentifier: routerPlacementIdentifier withReward: reward];
        
        // Clear grantedReward
        self.grantedReward = NO;
    }
    
    [self log: @"Rewarded ad hidden for instance ID: %@", instanceId];
    [self didHideAdForPlacementIdentifier: routerPlacementIdentifier];
}

- (void)rewardedVideoHasChangedAvailability:(BOOL)available instanceId:(NSString *)instanceId
{
    if ( available )
    {
        [self log: @"Rewarded ad loaded for instance ID: %@", instanceId];
        [self didLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]];
    }
    else
    {
        [self log: @"Rewarded ad failed to load for instance ID: %@", instanceId];
        [self didFailToLoadAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]
                                              error: MAAdapterError.noFill];
    }
}

- (void)rewardedVideoAdRewarded:(NSString *)instanceId
{
    [self log: @"Rewarded ad granted reward for instance ID: %@", instanceId];
    self.grantedReward = YES;
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId
{
    [self log: @"Rewarded ad failed to show for instance ID: %@ with error: %@", instanceId, error];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]
                                             error: [MAAdapterError errorWithCode: -4205
                                                                      errorString: @"Ad Display Failed"
                                                           thirdPartySdkErrorCode: error.code
                                                        thirdPartySdkErrorMessage: error.localizedDescription]];
#pragma clang diagnostic pop
}

- (void)rewardedVideoDidClick:(NSString *)instanceId
{
    [self log: @"Rewarded ad clicked for instance ID: %@", instanceId];
    [self didClickAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]];
}

#pragma mark - Utility Methods

+ (NSString *)interstitialRouterIdentifierForInstanceID:(NSString *)instanceID
{
    return [NSString stringWithFormat: @"%@-%@", instanceID, IS_INTERSTITIAL];
}

+ (NSString *)rewardedVideoRouterIdentifierForInstanceID:(NSString *)instanceID
{
    return [NSString stringWithFormat: @"%@-%@", instanceID, IS_REWARDED_VIDEO];
}

#pragma mark - ironSource Log Delegate

- (void)sendLog:(NSString *)log level:(ISLogLevel)level tag:(LogTag)tag
{
    [self log: log];
}

@end
