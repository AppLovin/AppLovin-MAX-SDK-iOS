//
//  ALInneractiveMediationAdapter.m
//  Adapters
//
//  Created by Christopher Cong on 10/11/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALInneractiveMediationAdapter.h"
#import <IASDKCore/IASDKCore.h>

#define ADAPTER_VERSION @"8.4.2.0"

@interface ALInneractiveMediationAdapterGlobalDelegate : NSObject <IAGlobalAdDelegate>
@end

@interface ALInneractiveMediationAdapterInterstitialDelegate : NSObject <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>
@property (nonatomic,   weak) ALInneractiveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALInneractiveMediationAdapterRewardedDelegate : NSObject <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>
@property (nonatomic,   weak) ALInneractiveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALInneractiveMediationAdapterAdViewDelegate : NSObject <IAUnitDelegate, IAMRAIDContentDelegate>
@property (nonatomic,   weak) ALInneractiveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALInneractiveMediationAdapter ()

// Interstitial
@property (nonatomic, strong) IAAdSpot *interstitialAdSpot;
@property (nonatomic, strong) IAFullscreenUnitController *interstitialUnitController;
@property (nonatomic, strong) ALInneractiveMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) IAAdSpot *rewardedAdSpot;
@property (nonatomic, strong) IAFullscreenUnitController *rewardedUnitController;
@property (nonatomic, strong) ALInneractiveMediationAdapterRewardedDelegate *rewardedDelegate;

// Ad View
@property (nonatomic, strong) IAAdSpot *adViewAdSpot;
@property (nonatomic, strong) IAViewUnitController *adViewUnitController;
@property (nonatomic, strong) ALInneractiveMediationAdapterAdViewDelegate *adViewDelegate;

// Content Controllers
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong) IAMRAIDContentController *MRAIDContentController;

@property (nonatomic, weak) UIViewController *presentingViewController;

@end

@implementation ALInneractiveMediationAdapter
static ALAtomicBoolean              *ALInneractiveInitialized;
static MAAdapterInitializationStatus ALInneractiveInitializationStatus = NSIntegerMin;

static ALInneractiveMediationAdapterGlobalDelegate *ALInneractiveGlobalDelegate;
static NSMutableDictionary<NSString *, ALInneractiveMediationAdapter *> *ALInneractiveCurrentlyShowingAdapters;

+ (void)initialize
{
    [super initialize];
    
    ALInneractiveInitialized = [[ALAtomicBoolean alloc] init];
    ALInneractiveGlobalDelegate = [[ALInneractiveMediationAdapterGlobalDelegate alloc] init];
    ALInneractiveCurrentlyShowingAdapters = [NSMutableDictionary dictionaryWithCapacity: 3];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALInneractiveInitialized compareAndSet: NO update: YES] )
    {
        ALInneractiveInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Inneractive SDK with app id: %@...", appID];
        [IASDKCore sharedInstance].mediationType = [[IAMediationMax alloc] init];
        
        [IASDKCore sharedInstance].globalAdDelegate = ALInneractiveGlobalDelegate;
        
        [[IASDKCore sharedInstance] setMediationType: [[IAMediationMax alloc] init]];
        
        [[IASDKCore sharedInstance] initWithAppID: appID completionBlock:^(BOOL success, NSError *_Nullable error) {
            
            if ( success )
            {
                [self log: @"Inneractive SDK initialized"];
                ALInneractiveInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALInneractiveInitializationStatus, nil);
            }
            else
            {
                [self log: @"Inneractive SDK failed to initialize with error: %@", error];
                ALInneractiveInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALInneractiveInitializationStatus, error.localizedDescription);
            }
        } completionQueue: nil]; // invokes completionBlock on main queue
    }
    else
    {
        completionHandler(ALInneractiveInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [[IASDKCore sharedInstance] version];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    [self.interstitialUnitController removeAd];
    self.interstitialAdSpot = nil;
    self.interstitialUnitController.unitDelegate = nil;
    self.interstitialUnitController = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedUnitController removeAd];
    self.rewardedAdSpot = nil;
    self.rewardedUnitController.unitDelegate = nil;
    self.rewardedUnitController = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;
    
    self.adViewAdSpot = nil;
    self.adViewUnitController.unitDelegate = nil;
    self.adViewUnitController = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
    
    self.videoContentController.videoContentDelegate = nil;
    self.MRAIDContentController.MRAIDContentDelegate = nil;
    self.videoContentController = nil;
    self.MRAIDContentController = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateUserInfoWithRequestParameters: parameters];
    
    NSString *signal = [FMPBiddingManager sharedInstance].biddingToken;
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading %@interstitial ad for spot id \"%@\"...", [parameters.bidResponse al_isValidString] ? @"bidding " : @"", parameters.thirdPartyAdPlacementIdentifier];
    
    [self updateUserInfoWithRequestParameters: parameters];
    
    IAAdRequest *request = [self createAdRequestWithRequestParameters: parameters];
    
    self.interstitialDelegate = [[ALInneractiveMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder> builder) {
        builder.videoContentDelegate = self.interstitialDelegate;
    }];
    
    self.MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder> builder) {
        builder.MRAIDContentDelegate = self.interstitialDelegate;
    }];
    
    self.interstitialUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> builder) {
        builder.unitDelegate = self.interstitialDelegate;
        
        [builder addSupportedContentController: self.videoContentController];
        [builder addSupportedContentController: self.MRAIDContentController];
    }];
    
    self.interstitialAdSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> builder) {
        builder.adRequest = request;
        [builder addSupportedUnitController: self.interstitialUnitController];
    }];
    
    __weak typeof(self) weakSelf = self;
    IAAdSpotAdResponseBlock adResponseBlock = ^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
        
        if ( !error )
        {
            [weakSelf log: @"Interstitial loaded"];
            [delegate didLoadInterstitialAd];
        }
        else
        {
            [weakSelf log: @"Interstitial failed to load with error: %@", error];
            [delegate didFailToLoadInterstitialAdWithError: [ALInneractiveMediationAdapter toMaxError: error]];
        }
    };
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self.interstitialAdSpot loadAdWithMarkup: parameters.bidResponse withCompletion: adResponseBlock];
    }
    else
    {
        [self.interstitialAdSpot fetchAdWithCompletion: adResponseBlock];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( self.interstitialAdSpot.activeUnitController == self.interstitialUnitController )
    {
        self.presentingViewController = parameters.presentingViewController;
        
        ALInneractiveCurrentlyShowingAdapters[parameters.thirdPartyAdPlacementIdentifier] = self;
        [self.interstitialUnitController showAdAnimated: YES completion: nil];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading %@rewarded ad for spot id \"%@\"...", [parameters.bidResponse al_isValidString] ? @"bidding " : @"", parameters.thirdPartyAdPlacementIdentifier];
    
    [self updateUserInfoWithRequestParameters: parameters];
    
    IAAdRequest *request = [self createAdRequestWithRequestParameters: parameters];
    
    self.rewardedDelegate = [[ALInneractiveMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder> builder) {
        builder.videoContentDelegate = self.rewardedDelegate;
    }];
    
    self.MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder> builder) {
        builder.MRAIDContentDelegate = self.rewardedDelegate;
    }];
    
    self.rewardedUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> builder) {
        builder.unitDelegate = self.rewardedDelegate;
        
        [builder addSupportedContentController: self.videoContentController];
        [builder addSupportedContentController: self.MRAIDContentController];
    }];
    
    self.rewardedAdSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> builder) {
        builder.adRequest = request;
        [builder addSupportedUnitController: self.rewardedUnitController];
    }];
    
    __weak typeof(self) weakSelf = self;
    IAAdSpotAdResponseBlock adResponseBlock = ^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
        
        if ( !error )
        {
            [weakSelf log: @"Rewarded ad loaded"];
            [delegate didLoadRewardedAd];
        }
        else
        {
            [weakSelf log: @"Rewarded ad failed to load with error: %@", error];
            [delegate didFailToLoadRewardedAdWithError: [ALInneractiveMediationAdapter toMaxError: error]];
        }
    };
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self.rewardedAdSpot loadAdWithMarkup: parameters.bidResponse withCompletion: adResponseBlock];
    }
    else
    {
        [self.rewardedAdSpot fetchAdWithCompletion: adResponseBlock];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( self.rewardedAdSpot.activeUnitController == self.rewardedUnitController )
    {
        ALInneractiveCurrentlyShowingAdapters[parameters.thirdPartyAdPlacementIdentifier] = self;
        
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        self.presentingViewController = parameters.presentingViewController;
        
        [self.rewardedUnitController showAdAnimated: YES completion: nil];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@%@ ad for spot id \"%@\"...", [parameters.bidResponse al_isValidString] ? @"bidding " : @"", adFormat.label, parameters.thirdPartyAdPlacementIdentifier];
    
    [self updateUserInfoWithRequestParameters: parameters];
    
    IAAdRequest *request = [self createAdRequestWithRequestParameters: parameters];
    
    self.adViewDelegate = [[ALInneractiveMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.MRAIDContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder> builder) {
        builder.MRAIDContentDelegate = self.adViewDelegate;
    }];
    
    self.adViewUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder> builder) {
        builder.unitDelegate = self.adViewDelegate;
        [builder addSupportedContentController: self.MRAIDContentController];
    }];
    
    self.adViewAdSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> builder) {
        builder.adRequest = request;
        [builder addSupportedUnitController: self.adViewUnitController];
    }];
    
    __weak typeof(self) weakSelf = self;
    IAAdSpotAdResponseBlock adResponseBlock = ^(IAAdSpot *_Nullable adSpot, IAAdModel *_Nullable adModel, NSError *_Nullable error) {
        if ( !error )
        {
            [weakSelf log: @"AdView loaded"];
            
            ALInneractiveCurrentlyShowingAdapters[parameters.thirdPartyAdPlacementIdentifier] = self;
            
            UIView *adViewContainer = [[UIView alloc] init];
            [weakSelf.adViewUnitController showAdInParentView: adViewContainer];
            [delegate didLoadAdForAdView: weakSelf.adViewUnitController.adView];
        }
        else
        {
            // NOTE: DO NOT PRINT `error` - logger crashes when printing `error` object
            [weakSelf log: @"AdView failed to load with error"];
            [delegate didFailToLoadAdViewAdWithError: [ALInneractiveMediationAdapter toMaxError: error]];
        }
    };
    
    if ( [parameters.bidResponse al_isValidString] )
    {
        [self.adViewAdSpot loadAdWithMarkup: parameters.bidResponse withCompletion: adResponseBlock];
    }
    else
    {
        [self.adViewAdSpot fetchAdWithCompletion: adResponseBlock];
    }
}

#pragma mark - Shared Methods

- (void)updateUserInfoWithRequestParameters:(id<MAAdapterParameters>)requestParameters
{
    NSNumber *hasUserConsent = [requestParameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        [[IASDKCore sharedInstance] setGDPRConsent: hasUserConsent.boolValue];
    }
    else
    {
        [[IASDKCore sharedInstance] clearGDPRConsentData];
    }
    
    if ( requestParameters.consentString )
    {
        [[IASDKCore sharedInstance] setGDPRConsentString: requestParameters.consentString];
    }
    
    NSNumber *isDoNotSell = [requestParameters isDoNotSell];
    if ( isDoNotSell != nil )
    {
        [[IASDKCore sharedInstance] setCCPAString: isDoNotSell.boolValue ? @"1YY-" : @"1YN-"];
    }
    else
    {
        [[IASDKCore sharedInstance] setCCPAString: @"1---"];
    }
}

- (IAAdRequest *)createAdRequestWithRequestParameters:(id<MAAdapterResponseParameters>)requestParameters
{
    IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder> builder) {
        builder.spotID = requestParameters.thirdPartyAdPlacementIdentifier;
        builder.timeout = [requestParameters.serverParameters al_numberForKey: @"load_timeout" defaultValue: @(10.0f)].al_timeIntervalValue;
    }];
    
    [self updateMuteStateFromServerParameters: requestParameters.serverParameters];
    
    return request;
}

- (void)updateMuteStateFromServerParameters:(NSDictionary<NSString *, id> *)serverParameters
{
    if ( [serverParameters al_containsValueForKey: @"is_muted"] )
    {
        [IASDKCore sharedInstance].muteAudio = [serverParameters al_numberForKey: @"is_muted"].boolValue;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)inneractiveError
{
    NSInteger inneractiveErrorCode = inneractiveError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( inneractiveErrorCode )
    {
        case 204:
            adapterError = MAAdapterError.noFill;
            break;
        case 496: // main timeout happened, ad wasn't loaded in time interval set in IAAdRequest
            adapterError = MAAdapterError.timeout;
            break;
        case 497: // config not ready / no valid config; it can occur for example if ad request happens early on app launch and SDK did not have enough time to download app config
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 499: // missing fetch completion block
        case 500: // internal error when got successful server ad response but status is neither 200 nor 204
            adapterError = MAAdapterError.internalError;
            break;
        case 495: // invalid spot ID provided in ad request (when SDK can't find this spot ID in current app config)
        case 498: // spot ID set in ad request is present in current app config, but it's set as not active there;
        case -1003:
        case -1004:
        case -1022: // ATS error
            adapterError = MAAdapterError.invalidConfiguration;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: inneractiveErrorCode
                     mediatedNetworkErrorMessage: inneractiveError.localizedDescription];
}

@end

@implementation ALInneractiveMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)IAParentViewControllerForUnitController:(nullable IAUnitController *)unitController
{
    return self.parentAdapter.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

- (void)IAAdDidExpire:(nullable IAUnitController *)unitController
{
    // Fyber SDK triggers this callback when attempting to display an expired ad. Fail the ad display to ensure that the ad display cycle is complete.
    [self.parentAdapter log: @"Interstitial expired"];
    [self.delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adExpiredError];
}

- (void)IAAdWillLogImpression:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"Interstitial shown"];
    
    dispatchOnMainQueueAfter(0.5, ^{
        // Force callback after a bit in case impression data does not arrive - note SDK guards against duplicate callbacks
        [self.delegate didDisplayInterstitialAd];
    });
    
}

- (void)IAAdDidReceiveClick:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)IAUnitControllerDidDismissFullscreen:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALInneractiveMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)IAParentViewControllerForUnitController:(nullable IAUnitController *)unitController
{
    return self.parentAdapter.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

- (void)IAAdDidExpire:(nullable IAUnitController *)unitController
{
    // Fyber SDK triggers this callback when attempting to display an expired ad. Fail the ad display to ensure that the ad display cycle is complete.
    [self.parentAdapter log: @"Rewarded ad expired"];
    [self.delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                     mediatedNetworkErrorCode: MAAdapterError.adExpiredError.code
                                                                  mediatedNetworkErrorMessage: MAAdapterError.adExpiredError.message]];
}

- (void)IAAdWillLogImpression:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    
    dispatchOnMainQueueAfter(0.5, ^{
        // Force callback after a bit in case impression data does not arrive - note SDK guards against duplicate callbacks
        [self.delegate didDisplayRewardedAd];
    });
}

- (void)IAVideoContentController:(nullable IAVideoContentController *)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime
{
    if ( currentTime == 0 )
    {
        [self.parentAdapter log: @"Rewarded video started"];
    }
}

- (void)IAAdDidReceiveClick:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)IAVideoContentController:(nullable IAVideoContentController *)contentController videoInterruptedWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded video is interrupted and buffering with error: %@", error];
}

- (void)IAVideoCompleted:(nullable IAVideoContentController *)contentController
{
    [self.parentAdapter log: @"Rewarded video completed"];
}

- (void)IAAdDidReward:(IAUnitController *)unitController
{
    [self.parentAdapter log: @"User earned reward"];
    self.grantedReward = YES;
}

- (void)IAUnitControllerDidDismissFullscreen:(nullable IAUnitController *)unitController
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALInneractiveMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALInneractiveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)IAParentViewControllerForUnitController:(nullable IAUnitController *)unitController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)IAAdWillLogImpression:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"AdView shown"];
}

- (void)IAAdDidReceiveClick:(nullable IAUnitController *)unitController
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)IAMRAIDContentController:(nullable IAMRAIDContentController *)contentController MRAIDAdDidExpandToFrame:(CGRect)frame
{
    [self.parentAdapter log: @"AdView expanded"];
    [self.delegate didExpandAdViewAd];
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(nullable IAMRAIDContentController *)contentController
{
    [self.parentAdapter log: @"AdView contracted"];
    [self.delegate didCollapseAdViewAd];
}

@end

@implementation ALInneractiveMediationAdapterGlobalDelegate

// NOTE: Only AppLovin SDK 6.15.0+ registers for this callback
- (void)adDidShowWithImpressionData:(IAImpressionData *)impressionData withAdRequest:(IAAdRequest *)adRequest
{
    NSString *placementID = adRequest.spotID;
    if ( ![placementID al_isValidString] ) return;
    
    NSString *creativeID = impressionData.creativeID;
    
    ALInneractiveMediationAdapter *adapter = ALInneractiveCurrentlyShowingAdapters[placementID];
    [ALInneractiveCurrentlyShowingAdapters removeObjectForKey: placementID];
    
    if ( adapter.interstitialDelegate )
    {
        if ( [creativeID al_isValidString] )
        {
            [adapter.interstitialDelegate.delegate didDisplayInterstitialAdWithExtraInfo: @{@"creative_id" : creativeID}];
        }
        else
        {
            [adapter.interstitialDelegate.delegate didDisplayInterstitialAd];
        }
    }
    else if ( adapter.rewardedDelegate )
    {
        if ( [creativeID al_isValidString] )
        {
            [adapter.rewardedDelegate.delegate didDisplayRewardedAdWithExtraInfo: @{@"creative_id" : creativeID}];
        }
        else
        {
            [adapter.rewardedDelegate.delegate didDisplayRewardedAd];
        }
    }
    else if ( adapter.adViewDelegate )
    {
        if ( [creativeID al_isValidString] )
        {
            [adapter.adViewDelegate.delegate didDisplayAdViewAdWithExtraInfo: @{@"creative_id" : creativeID}];
        }
        else
        {
            [adapter.adViewDelegate.delegate didDisplayAdViewAd];
        }
    }
}

@end
