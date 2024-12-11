//
//  ALIronSourceMediationAdapter.m
//  AppLovinSDK
//
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALIronSourceMediationAdapter.h"
#import <IronSource/IronSource.h>

#define ADAPTER_VERSION @"8.5.1.0.0"

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

@interface ALIronSourceInterstitialAdDelegate : NSObject <ISAInterstitialAdLoaderDelegate, ISAInterstitialAdDelegate>
@property (nonatomic,   weak) ALIronSourceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALIronSourceRewardedAdDelegate : NSObject <ISARewardedAdLoaderDelegate, ISARewardedAdDelegate>
@property (nonatomic,   weak) ALIronSourceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALIronSourceAdViewAdDelegate : NSObject <ISABannerAdLoaderDelegate, ISABannerAdViewDelegate>
@property (nonatomic,   weak) ALIronSourceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALIronSourceMediationAdapter ()
@property (nonatomic, strong, readonly) ALIronSourceMediationAdapterRouter *router;
@property (nonatomic,   copy) NSString *routerPlacementIdentifier;
@property (nonatomic,   copy, nullable) NSString *adViewPlacementIdentifier;

@property (nonatomic, strong) ALIronSourceMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Bidding Interstitial
@property (nonatomic, strong) ISAInterstitialAd *biddingInterstitialAd;
@property (nonatomic, strong) ALIronSourceInterstitialAdDelegate *biddingInterstitialAdDelegate;

// Bidding Rewarded
@property (nonatomic, strong) ISARewardedAd *biddingRewardedAd;
@property (nonatomic, strong) ALIronSourceRewardedAdDelegate *biddingRewardedAdDelegate;

// Bidding AdView
@property (nonatomic, strong) ISABannerAdView *biddingAdViewAd;
@property (nonatomic, strong) ALIronSourceAdViewAdDelegate *biddingAdViewAdDelegate;
@end

@implementation ALIronSourceMediationAdapter
@dynamic router;

static NSMutableArray<NSString *> *ALLoadedAdViewPlacementIdentifiers;
static NSObject *ALLoadedAdViewPlacementIdentifiersLock;
static ALAtomicBoolean *ALIronSourceInitialized;
static MAAdapterInitializationStatus ALIronSourceInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALIronSourceInitialized = [[ALAtomicBoolean alloc] init];
    
    ALLoadedAdViewPlacementIdentifiers = [NSMutableArray array];
    ALLoadedAdViewPlacementIdentifiersLock = [[NSObject alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALIronSourceInitialized compareAndSet: NO update: YES] )
    {
        NSString *appKey = [parameters.serverParameters al_stringForKey: @"app_key"];
        [self log: @"Initializing IronSource SDK with app key: %@...", appKey];
        
        ALIronSourceInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        if ( [parameters isTesting] )
        {
            [IronSource setAdaptersDebug: YES];
            [IronSource setLogDelegate: self.router];
        }
        
        [IronSource setMediationType: [NSString stringWithFormat:@"MAX%luSDK%lu", self.adapterVersionCode, ALSdk.versionCode]];
        
        [self setPrivacySettingsWithParameters: parameters];
        
        NSNumber *isDoNotSell = [parameters isDoNotSell];
        if ( isDoNotSell != nil )
        {
            // NOTE: `setMetaData` must be called _before_ initializing their SDK
            [IronSource setMetaDataWithKey: @"do_not_sell" value: isDoNotSell.boolValue ? @"YES" : @"NO"];
        }
        
        [self updateIronSourceDelegates];
        
        ISAInitRequestBuilder *requestBuilder = [[[ISAInitRequestBuilder alloc] initWithAppKey: appKey] withLegacyAdFormats: [self adFormatsToInitializeFromParameters: parameters]];
        
        if ( [parameters isTesting] )
        {
            [requestBuilder withLogLevel: ISALogLevelVerbose];
        }
        
        ISAInitRequest *request = [requestBuilder build];
        
        [IronSourceAds initWithRequest: request completion:^(BOOL success, NSError *_Nullable error) {
            
            if ( !success || error )
            {
                [self log: @"IronSource SDK failed to initialize with error: %@", error];
                
                ALIronSourceInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALIronSourceInitializationStatus, error.localizedDescription);
                return;
            }
            
            [self log: @"IronSource SDK initialized"];
            
            ALIronSourceInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALIronSourceInitializationStatus, nil);
        }];
    }
    else
    {
        completionHandler(ALIronSourceInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [IronSource sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (NSUInteger)adapterVersionCode
{
    NSString *simplifiedVersionString = [self.adapterVersion stringByReplacingOccurrencesOfString: @"[^0-9.]+"
                                                                                       withString: @""
                                                                                          options: NSRegularExpressionSearch
                                                                                            range: NSMakeRange(0, self.adapterVersion.length)];
    NSArray<NSString *> *versionNums = [simplifiedVersionString componentsSeparatedByString: @"."];
    
    NSUInteger versionCode = 0;
    for ( NSString *num in versionNums )
    {
        versionCode *= 100;
        
        if ( versionCode != 0 && num.length > 2 )
        {
            versionCode += [num substringToIndex: 2].intValue;
        }
        else
        {
            versionCode += num.intValue;
        }
    }
    
    return versionCode;
}

- (void)destroy
{
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    if ( self.adViewPlacementIdentifier )
    {
        [self log: @"Destroying adview with instance ID: %@ ", self.adViewPlacementIdentifier];
        
        [IronSource destroyISDemandOnlyBannerWithInstanceId: self.adViewPlacementIdentifier];
        
        @synchronized ( ALLoadedAdViewPlacementIdentifiersLock )
        {
            [ALLoadedAdViewPlacementIdentifiers removeObject: self.adViewPlacementIdentifier];
        }
    }
    
    [self.router removeAdapter: self forPlacementIdentifier: self.routerPlacementIdentifier];
    
    self.biddingInterstitialAd.delegate = nil;
    self.biddingInterstitialAd = nil;
    self.biddingInterstitialAdDelegate.delegate = nil;
    self.biddingInterstitialAdDelegate = nil;
    
    self.biddingRewardedAd.delegate = nil;
    self.biddingRewardedAd = nil;
    self.biddingRewardedAdDelegate.delegate = nil;
    self.biddingRewardedAdDelegate = nil;
    
    self.biddingAdViewAd.delegate = nil;
    self.biddingAdViewAd = nil;
    self.biddingAdViewAdDelegate.delegate = nil;
    self.biddingAdViewAdDelegate = nil;
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
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    [self log: @"Loading ironSource %@interstitial for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    [self setPrivacySettingsWithParameters: parameters];
    
    if ( isBiddingAd )
    {
        ISAInterstitialAdRequest *adRequest = [[[ISAInterstitialAdRequestBuilder alloc] initWithInstanceId: instanceID adm: bidResponse] build];
        self.biddingInterstitialAdDelegate = [[ALIronSourceInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        [ISAInterstitialAdLoader loadAdWithAdRequest: adRequest delegate: self.biddingInterstitialAdDelegate];
    }
    else
    {
        [self updateIronSourceDelegates];
        
        // Create a format specific router identifier to ensure that the router can distinguish between them.
        self.routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceID];
        [self.router addInterstitialAdapter: self
                                   delegate: delegate
                     forPlacementIdentifier: self.routerPlacementIdentifier];
        
        if ( [IronSource hasISDemandOnlyInterstitial: instanceID] )
        {
            [self log: @"Ad is available already for instance ID: %@", instanceID];
            [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifier];
            return;
        }
        
        [IronSource loadISDemandOnlyInterstitial: instanceID];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    [self log: @"Showing ironSource %@interstitial for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    if ( isBiddingAd )
    {
        if ( !self.biddingInterstitialAd || !self.biddingInterstitialAd.isReadyToShow )
        {
            [self log: @"Unable to show ironSource bidding interstitial - no ad loaded for instance ID: %@", instanceID];
            [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                                 errorString: @"Ad Display Failed"
                                                                    mediatedNetworkErrorCode: 0
                                                                 mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
            return;
        }
        
        self.biddingInterstitialAd.delegate = self.biddingInterstitialAdDelegate;
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.biddingInterstitialAd showFromViewController: presentingViewController];
    }
    else
    {
        [self updateIronSourceDelegates];
        [self.router addShowingAdapter: self];

        if ( ![IronSource hasISDemandOnlyInterstitial: instanceID] )
        {
            [self log: @"Unable to show ironSource interstitial - no ad loaded for instance ID: %@", instanceID];
            [self.router didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceID]
                                                            error: [MAAdapterError errorWithCode: -4205
                                                                                     errorString: @"Ad Display Failed"
                                                                        mediatedNetworkErrorCode: 0
                                                                     mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
            return;
            
        }
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [IronSource showISDemandOnlyInterstitial: presentingViewController instanceId: instanceID];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    [self log: @"Loading ironSource %@rewarded for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    [self setPrivacySettingsWithParameters: parameters];
    
    if ( isBiddingAd )
    {
        ISARewardedAdRequest *adRequest = [[[ISARewardedAdRequestBuilder alloc] initWithInstanceId: instanceID adm: bidResponse] build];
        self.biddingRewardedAdDelegate = [[ALIronSourceRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        [ISARewardedAdLoader loadAdWithAdRequest: adRequest delegate: self.biddingRewardedAdDelegate];
    }
    else
    {
        [self updateIronSourceDelegates];
        
        // Create a format specific router identifier to ensure that the router can distinguish between them.
        self.routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceID];
        [self.router addRewardedAdapter: self delegate: delegate forPlacementIdentifier: self.routerPlacementIdentifier];
        
        if ( [IronSource hasISDemandOnlyRewardedVideo: instanceID] )
        {
            [self log: @"Ad is available already for instance ID: %@", instanceID];
            [self.router didLoadAdForPlacementIdentifier: self.routerPlacementIdentifier];
            return;
        }
        
        [IronSource loadISDemandOnlyRewardedVideo: instanceID];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    [self log: @"Showing ironSource %@rewarded for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), instanceID];
    
    if ( isBiddingAd )
    {
        if ( !self.biddingRewardedAd || !self.biddingRewardedAd.isReadyToShow )
        {
            [self log: @"Unable to show ironSource bidding rewarded - no ad loaded for instance ID: %@", instanceID];
            [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                mediatedNetworkErrorCode: 0
                                                             mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];
            
            return;
        }
        
        // Configure reward from server.
        [self configureRewardForParameters: parameters];

        self.biddingRewardedAd.delegate = self.biddingRewardedAdDelegate;
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.biddingRewardedAd showFromViewController: presentingViewController];
    }
    else
    {
        [self updateIronSourceDelegates];
        [self.router addShowingAdapter: self];

        if ( ![IronSource hasISDemandOnlyRewardedVideo: instanceID] )
        {
            [self log: @"Unable to show ironSource rewarded - no ad loaded for instance ID: %@", instanceID];
            [self.router didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceID]
                                                            error: [MAAdapterError errorWithCode: -4205
                                                                                     errorString: @"Ad Display Failed"
                                                                        mediatedNetworkErrorCode: 0
                                                                     mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];
            return;
        }
        
        // Configure reward from server.
        [self configureRewardForParameters: parameters];

        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [IronSource showISDemandOnlyRewardedVideo: presentingViewController instanceId: instanceID];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *instanceID = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBiddingAd = [bidResponse al_isValidString];
    [self log: @"Loading ironSource %@%@ ad for instance ID: %@", ( isBiddingAd ? @"bidding " : @"" ), adFormat.label, instanceID];
    
    [self setPrivacySettingsWithParameters: parameters];
    
    __block UIViewController *presentingViewController;
    dispatchSyncOnMainQueue(^{
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    });
    
    if ( isBiddingAd )
    {
        ISABannerAdRequestBuilder *requestBuilder = [[ISABannerAdRequestBuilder alloc] initWithInstanceId: instanceID adm: bidResponse size: [self toISAAdSize: adFormat]];
        ISABannerAdRequest *adRequest = [[requestBuilder withViewController: presentingViewController] build];
        self.biddingAdViewAdDelegate = [[ALIronSourceAdViewAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        
        [ISABannerAdLoader loadAdWithAdRequest: adRequest delegate: self.biddingAdViewAdDelegate];
    }
    else
    {
        @synchronized ( ALLoadedAdViewPlacementIdentifiersLock )
        {
            // IronSource does not support b2b with same instance id for banners/MRECs
            if ( [ALLoadedAdViewPlacementIdentifiers containsObject: instanceID] )
            {
                [self log: @"AdView failed to load for instance ID: %@. An ad with the same instance ID is already loaded", parameters.thirdPartyAdPlacementIdentifier];
                [delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithCode: MAAdapterError.internalError.code
                                                                            errorString: MAAdapterError.internalError.message
                                                               mediatedNetworkErrorCode: 0
                                                            mediatedNetworkErrorMessage: @"An ad with the same instance ID is already loaded"]];
                return;
            }
        }
        
        self.adViewPlacementIdentifier = instanceID; // Set it only if it is not an instance id of an already loaded ad to avoid destroying the currently showing ad
        
        self.adViewAdapterDelegate = [[ALIronSourceMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        [IronSource setISDemandOnlyBannerDelegate: self.adViewAdapterDelegate forInstanceId: self.adViewPlacementIdentifier];
        
        [IronSource loadISDemandOnlyBannerWithInstanceId: self.adViewPlacementIdentifier
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

- (NSArray<ISAAdFormat *> *)adFormatsToInitializeFromParameters:(id<MAAdapterInitializationParameters>)parameters
{
    ISAAdFormat *rewarded = [[ISAAdFormat alloc] initWithAdFormatType: ISAAdFormatTypeRewarded];
    ISAAdFormat *interstitial = [[ISAAdFormat alloc] initWithAdFormatType: ISAAdFormatTypeInterstitial];
    ISAAdFormat *banner = [[ISAAdFormat alloc] initWithAdFormatType: ISAAdFormatTypeBanner];

    NSArray<NSString *> *adFormats = [parameters.serverParameters al_arrayForKey: @"init_ad_formats"];
    if ( adFormats.count == 0 )
    {
        // Default to initialize all ad formats if backend doesn't send down which ones to initialize
        return @[rewarded, interstitial, banner];
    }
    
    NSMutableArray<ISAAdFormat *> *adFormatsToInitialize = [NSMutableArray array];
    if ( [adFormats containsObject: @"inter"] )
    {
        [adFormatsToInitialize addObject: interstitial];
    }
    
    if ( [adFormats containsObject: @"rewarded"] )
    {
        [adFormatsToInitialize addObject: rewarded];
    }
    
    if ( [adFormats containsObject: @"banner"] )
    {
        [adFormatsToInitialize addObject: banner];
    }
    
    return adFormatsToInitialize;
}

- (ISAAdSize *)toISAAdSize:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return [ISAAdSize banner];
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return [ISAAdSize leaderboard];
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return [ISAAdSize mediumRectangle];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return [ISAAdSize banner];
    }
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
        case 7101:
        case 7102:
        case 7103:
        case 7104:
        case 7105:
        case 7106:
        case 7107:
        case 7108:
        case 7109:
        case 7110:
        case 7111:
        case 7112:
        case 7116:
        case 7117:
        case 7118:
        case 7201:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 508: // Init failure
        case 7001:
        case 7002:
        case 7003:
        case 7004:
        case 7115:
            adapterError = MAAdapterError.notInitialized;
            break;
        case 509: // No ads to show (Show Fail)
        case 606: // There is no available ad to load
        case 621: // No available ad to load
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
        case 7113:
            adapterError = MAAdapterError.timeout;
            break;
        case 1023: // Show RV called when no available ads to show (Show Fail)
        case 7202:
            adapterError = MAAdapterError.adNotReady;
            break;
        case 1036: // Interstitial already showing (Show Fail)
        case 1037: // Interstitial already loaded (Load Fail)
        case 1022: // RV already showing (Show Fail)
        case 1056: // RV already loaded (Load Fail)
            adapterError = MAAdapterError.invalidLoadState;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                mediatedNetworkErrorCode: ironSourceErrorCode
             mediatedNetworkErrorMessage: ironSourceError.localizedDescription];
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
    @synchronized ( ALLoadedAdViewPlacementIdentifiersLock )
    {
        [ALLoadedAdViewPlacementIdentifiers addObject: instanceId];
    }
    
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
    [self didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter interstitialRouterIdentifierForInstanceID: instanceId]
                                             error: [MAAdapterError errorWithCode: -4205
                                                                      errorString: @"Ad Display Failed"
                                                         mediatedNetworkErrorCode: error.code
                                                      mediatedNetworkErrorMessage: error.localizedDescription]];
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
}

- (void)rewardedVideoDidClose:(NSString *)instanceId
{
    NSString *routerPlacementIdentifier = [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId];
    
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
    [self didFailToDisplayAdForPlacementIdentifier: [ALIronSourceMediationAdapterRouter rewardedVideoRouterIdentifierForInstanceID: instanceId]
                                             error: [MAAdapterError errorWithCode: -4205
                                                                      errorString: @"Ad Display Failed"
                                                         mediatedNetworkErrorCode: error.code
                                                      mediatedNetworkErrorMessage: error.localizedDescription]];
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

@implementation ALIronSourceInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(ISAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad loaded for instance ID: %@", interstitialAd.adInfo.instanceId];
    self.parentAdapter.biddingInterstitialAd = interstitialAd;
    
    NSDictionary *extraInfo = [interstitialAd.adInfo.adId al_isValidString] ? @{@"creative_id" : interstitialAd.adInfo.adId} : nil;
    [self.delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
}

- (void)interstitialAdDidFailToLoadWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialAdDidShow:(ISAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad opened for instance ID: %@", interstitialAd.adInfo.instanceId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAd:(ISAInterstitialAd *)interstitialAd didFailToShowWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad failed to show for instance ID: %@ with error: %@", interstitialAd.adInfo.instanceId, error];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialAdDidClick:(ISAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad clicked for instance ID: %@", interstitialAd.adInfo.instanceId];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdDidDismiss:(ISAInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad hidden for instance ID: %@", interstitialAd.adInfo.instanceId];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALIronSourceRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALIronSourceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedAdDidLoad:(ISARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad loaded for instance ID: %@", rewardedAd.adInfo.instanceId];
    self.parentAdapter.biddingRewardedAd = rewardedAd;
    
    NSDictionary *extraInfo = [rewardedAd.adInfo.adId al_isValidString] ? @{@"creative_id" : rewardedAd.adInfo.adId} : nil;
    [self.delegate didLoadRewardedAdWithExtraInfo: extraInfo];
}

- (void)rewardedAdDidFailToLoadWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidShow:(ISARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad shown for instance ID: %@", rewardedAd.adInfo.instanceId];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedAd:(ISARewardedAd *)rewardedAd didFailToShowWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad failed to show for instance ID: %@ with error: %@", rewardedAd.adInfo.instanceId, adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedAdDidClick:(ISARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad clicked for instance ID: %@", rewardedAd.adInfo.instanceId];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAdDidUserEarnReward:(ISARewardedAd *)rewardedAd
{
    [self.parentAdapter log: @"Rewarded ad granted reward for instance ID: %@", rewardedAd.adInfo.instanceId];
    self.grantedReward = YES;
}

- (void)rewardedAdDidDismiss:(ISARewardedAd *)rewardedAd
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden for instance ID: %@", rewardedAd.adInfo.instanceId];
    [self.delegate didHideRewardedAd];
}

@end

@implementation ALIronSourceAdViewAdDelegate

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

- (void)bannerAdDidLoad:(ISABannerAdView *)bannerAdView
{
    [self.parentAdapter log: @"AdView ad loaded for instance ID: %@", bannerAdView.adInfo.instanceId];
    
    self.parentAdapter.biddingAdViewAd = bannerAdView;
    self.parentAdapter.biddingAdViewAd.delegate = self;
    
    NSDictionary *extraInfo = [bannerAdView.adInfo.adId al_isValidString] ? @{@"creative_id" : bannerAdView.adInfo.adId} : nil;
    [self.delegate didLoadAdForAdView: bannerAdView withExtraInfo: extraInfo];
}

- (void)bannerAdDidFailToLoadWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALIronSourceMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerAdViewDidShow:(ISABannerAdView *)bannerAdView
{
    [self.parentAdapter log: @"AdView shown for instance ID: %@", bannerAdView.adInfo.instanceId];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerAdViewDidClick:(ISABannerAdView *)bannerAdView
{
    [self.parentAdapter log: @"AdView clicked for instance ID: %@", bannerAdView.adInfo.instanceId];
    [self.delegate didClickAdViewAd];
}

@end
