//
//  MAFacebookMediationAdapter.m
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALFacebookMediationAdapter.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

#define ADAPTER_VERSION @"6.20.1.0"
#define MEDIATION_IDENTIFIER [NSString stringWithFormat: @"APPLOVIN_%@:%@", [ALSdk version], self.adapterVersion]
#define ICON_VIEW_TAG            3

@interface ALFacebookMediationAdapterInterstitialAdDelegate : NSObject <FBInterstitialAdDelegate>
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALFacebookMediationAdapterRewardedVideoAdDelegate : NSObject <FBRewardedVideoAdDelegate>
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALFacebookMediationAdapterAdViewDelegate : NSObject <FBAdViewDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALFacebookMediationAdapterNativeAdViewAdDelegate : NSObject <FBNativeAdDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALFacebookMediationAdapterNativeAdDelegate : NSObject <FBNativeAdDelegate>
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface ALFacebookMediationAdapterNativeBannerAdDelegate : NSObject <FBNativeBannerAdDelegate>
@property (nonatomic,   weak) ALFacebookMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAFacebookNativeAd : MANativeAd
@property (nonatomic, weak) ALFacebookMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALFacebookMediationAdapter ()

@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) FBAdView *adView;
@property (nonatomic, strong) FBNativeAd *nativeAd;
@property (nonatomic, strong) FBNativeBannerAd *nativeBannerAd;

@property (nonatomic, strong) ALFacebookMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALFacebookMediationAdapterRewardedVideoAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALFacebookMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALFacebookMediationAdapterNativeAdViewAdDelegate *nativeAdViewAdAdapterDelegate;
@property (nonatomic, strong) ALFacebookMediationAdapterNativeAdDelegate *nativeAdAdapterDelegate;
@property (nonatomic, strong) ALFacebookMediationAdapterNativeBannerAdDelegate *nativeBannerAdAdapterDelegate;

@end

@implementation ALFacebookMediationAdapter

static NSObject *ALFBAdSettingsLock;
static ALAtomicBoolean              *ALFacebookSDKInitialized;
static MAAdapterInitializationStatus ALFacebookSDKInitializationStatus = NSIntegerMin;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALFBAdSettingsLock = [[NSObject alloc] init];
    ALFacebookSDKInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self updateAdSettingsWithParameters: parameters];
    
    // If initialized already
    if ( [ALFacebookSDKInitialized compareAndSet: NO update: YES] )
    {
        ALFacebookSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSArray<NSString *> *placementIDs = [parameters.serverParameters al_arrayForKey: @"placement_ids"];
        void (^facebookCompletionHandler)(FBAdInitResults *results) = ^(FBAdInitResults *initResult) {
            
            if ( [initResult isSuccess] )
            {
                [self log: @"Facebook SDK successfully finished initialization: %@", initResult.message];
                
                ALFacebookSDKInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALFacebookSDKInitializationStatus, nil);
            }
            else
            {
                [self log: @"Facebook SDK failed to finished initialization: %@", initResult.message];
                
                ALFacebookSDKInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALFacebookSDKInitializationStatus, initResult.message);
            }
        };
        
        [self log: @"Initializing Facebook SDK with placements: %@", placementIDs];
        
        FBAdInitSettings *initSettings = [[FBAdInitSettings alloc] initWithPlacementIDs: placementIDs mediationService: MEDIATION_IDENTIFIER];
        [FBAudienceNetworkAds initializeWithSettings: initSettings completionHandler: facebookCompletionHandler];
    }
    else
    {
        completionHandler(ALFacebookSDKInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return FB_AD_SDK_VERSION;
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedVideoAd.delegate = nil;
    self.rewardedVideoAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdViewAdAdapterDelegate.delegate = nil;
    self.nativeAdViewAdAdapterDelegate = nil;
    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate = nil;
    
    [self.nativeBannerAd unregisterView];
    self.nativeBannerAd.delegate = nil;
    self.nativeBannerAd = nil;
    self.nativeBannerAdAdapterDelegate.delegate = nil;
    self.nativeBannerAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateAdSettingsWithParameters: parameters];
    
    NSString *signal = FBAdSettings.bidderToken;
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading interstitial ad: %@...", placementIdentifier];
    
    [self updateAdSettingsWithParameters: parameters];
    
    self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID: placementIdentifier];
    self.interstitialAdapterDelegate = [[ALFacebookMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    [self log: @"Loading bidding interstitial ad..."];
    [self.interstitialAd loadAdWithBidPayload: parameters.bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    // Check if ad is already expired or invalidated, and do not show ad if that is the case. You will not get paid to show an invalidated ad.
    if ( [self.interstitialAd isAdValid] )
    {
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.interstitialAd showAdFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"Unable to show interstitial ad: ad is not valid - marking as expired"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adExpiredError.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adExpiredError.message]];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading rewarded ad: %@...", placementIdentifier];
    
    [self updateAdSettingsWithParameters: parameters];
    
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID: placementIdentifier];
    self.rewardedAdapterDelegate = [[ALFacebookMediationAdapterRewardedVideoAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedVideoAd.delegate = self.rewardedAdapterDelegate;
    
    if ( [self.rewardedVideoAd isAdValid] )
    {
        [self log: @"A rewarded ad has been loaded already"];
        [delegate didLoadRewardedAd];
    }
    else
    {
        [self log: @"Loading bidding rewarded ad..."];
        [self.rewardedVideoAd loadAdWithBidPayload: parameters.bidResponse];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad: %@...", parameters.thirdPartyAdPlacementIdentifier];
    
    // Check if ad is already expired or invalidated, and do not show ad if that is the case. You will not get paid to show an invalidated ad.
    if ( [self.rewardedVideoAd isAdValid] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.rewardedVideoAd showAdFromRootViewController: presentingViewController];
    }
    else
    {
        [self log: @"Unable to show rewarded ad: ad is not valid - marking as expired"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adExpiredError.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adExpiredError.message]];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    
    [self log: @"Loading%@%@ ad: %@...", isNative ? @" native " : @" ", adFormat.label, placementIdentifier];
    
    [self updateAdSettingsWithParameters: parameters];
    
    // NOTE: FB native is no longer supported in banners but is kept in for backwards compatibility for existing users.
    if ( isNative )
    {
        self.nativeAd = [[FBNativeAd alloc] initWithPlacementID: placementIdentifier];
        self.nativeAdViewAdAdapterDelegate = [[ALFacebookMediationAdapterNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                                            serverParameters: parameters.serverParameters
                                                                                                                      format: adFormat
                                                                                                                   andNotify: delegate];
        self.nativeAd.delegate = self.nativeAdViewAdAdapterDelegate;
        
        [self log: @"Loading bidding native %@ ad...", adFormat.label];
        [self.nativeAd loadAdWithBidPayload: parameters.bidResponse];
    }
    else
    {
        FBAdSize adSize = [self FBAdSizeFromAdFormat: adFormat];
        
        self.adView = [[FBAdView alloc] initWithPlacementID: placementIdentifier
                                                     adSize: adSize
                                         rootViewController: [ALUtils topViewControllerFromKeyWindow]];
        self.adView.frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
        self.adViewAdapterDelegate = [[ALFacebookMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                      format: adFormat
                                                                                                   andNotify: delegate];
        self.adView.delegate = self.adViewAdapterDelegate;
        
        [self log: @"Loading bidding %@ ad...", adFormat.label];
        [self.adView loadAdWithBidPayload: parameters.bidResponse];
    }
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
    BOOL isNativeBanner = [serverParameters al_boolForKey: @"is_native_banner"];
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native %@ad: %@...", isNativeBanner ? @"banner " : @"" , placementIdentifier];
    
    [self updateAdSettingsWithParameters: parameters];
    
    if ( isNativeBanner )
    {
        self.nativeBannerAd = [[FBNativeBannerAd alloc] initWithPlacementID: placementIdentifier];
        self.nativeBannerAdAdapterDelegate = [[ALFacebookMediationAdapterNativeBannerAdDelegate alloc] initWithParentAdapter: self
                                                                                                            serverParameters: serverParameters
                                                                                                                   andNotify: delegate];
        self.nativeBannerAd.delegate = self.nativeBannerAdAdapterDelegate;
        
        dispatchOnMainQueue(^{
            [self.nativeBannerAd loadAdWithBidPayload: parameters.bidResponse];
        });
    }
    else
    {
        self.nativeAd = [[FBNativeAd alloc] initWithPlacementID: placementIdentifier];
        self.nativeAdAdapterDelegate = [[ALFacebookMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                                serverParameters: serverParameters
                                                                                                       andNotify: delegate];
        self.nativeAd.delegate = self.nativeAdAdapterDelegate;
        
        dispatchOnMainQueue(^{
            [self.nativeAd loadAdWithBidPayload: parameters.bidResponse];
        });
    }
}

#pragma mark - Shared Methods

- (void)updateAdSettingsWithParameters:(id<MAAdapterParameters>)parameters
{
    // FBAdSettings is apparently not thread-safe on iOS - and may occassionally crash :/
    @synchronized ( ALFBAdSettingsLock )
    {
        NSString *testDevicesString = parameters.serverParameters[@"test_device_ids"];
        if ( [testDevicesString al_isValidString] )
        {
            NSArray<NSString *> *testDevices = [testDevicesString componentsSeparatedByString: @","];
            [FBAdSettings addTestDevices: testDevices];
        }
        
        if ( [parameters isTesting] )
        {
            [FBAdSettings setLogLevel: FBAdLogLevelDebug];
        }
        
        [FBAdSettings setMediationService: MEDIATION_IDENTIFIER];
    }
}

- (FBAdSize)FBAdSizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kFBAdSizeHeight50Banner;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return kFBAdSizeHeight90Banner;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kFBAdSizeHeight250Rectangle;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        
        return kFBAdSizeHeight50Banner;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)facebookError
{
    // From https://developers.facebook.com/docs/audience-network/testing/#errors
    NSInteger facebookErrorCode = facebookError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( facebookErrorCode )
    {
        case 1000: // Network Error
            adapterError = MAAdapterError.noConnection;
            break;
        case 1001: // No Fill
            adapterError = MAAdapterError.noFill;
            break;
        case 1002: // Ad Load Too Frequently
        case 1203: // Not An App Admin, Developer or Tester
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case 1011: // Display Format Mismatch
        case 1012: // Unsupported SDK Version for New Apps
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 2000: // Server Error
            adapterError = MAAdapterError.serverError;
            break;
        case 2001: // Internal Error - actually a timeout error
            adapterError = MAAdapterError.timeout;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: facebookErrorCode
                     mediatedNetworkErrorMessage: facebookError.localizedDescription];
}

- (void)renderTrueNativeAd:(FBNativeAdBase *)nativeAd
          serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                 andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    // `nativeAd` may be nil if the adapter is destroyed before the ad loaded (timed out).
    if ( !nativeAd )
    {
        [self log: @"Native ad failed to load: no fill"];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![nativeAd isAdValid] )
    {
        [self log: @"Native ad failed to load: ad is no longer valid"];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    
    NSString *templateName = [serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.headline al_isValidString] )
    {
        [self e: @"Native ad (%@) does not have required assets.", nativeAd];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
        
        return;
    }
    
    // Ensure UI rendering is done on main queue
    dispatchOnMainQueue(^{
        
        MANativeAd *maxNativeAd = [[MAFacebookNativeAd alloc] initWithParentAdapter: self builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.headline;
            builder.advertiser = nativeAd.advertiserName;
            builder.body = nativeAd.bodyText;
            builder.callToAction = nativeAd.callToAction;
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.iconImage];
            
            FBAdOptionsView *adOptionsView = [[FBAdOptionsView alloc] init];
            adOptionsView.nativeAd = nativeAd;
            adOptionsView.backgroundColor = UIColor.clearColor;
            builder.optionsView = adOptionsView;
            
            if ( self.nativeBannerAd )
            {
                // Facebook true native banners do not provide media views so use icon asset in place of it
                UIImageView *mediaImageView = [[UIImageView alloc] initWithImage: nativeAd.iconImage];
                builder.mediaView = mediaImageView;
                
                builder.mediaContentAspectRatio = nativeAd.iconImage.size.width / nativeAd.iconImage.size.height;
            }
            else
            {
                FBMediaView *mediaView = [[FBMediaView alloc] init];
                builder.mediaView = mediaView;
                
                builder.mediaContentAspectRatio = mediaView.aspectRatio;
            }
        }];
        
        [delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

@end

@implementation ALFacebookMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", interstitialAd.placementID];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial ad (%@) failed to load with error: %@", interstitialAd.placementID, adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad shown: %@", interstitialAd.placementID];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad clicked: %@", interstitialAd.placementID];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    [self.parentAdapter log: @"Interstitial ad hidden: %@", interstitialAd.placementID];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALFacebookMediationAdapterRewardedVideoAdDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad loaded: %@", rewardedVideoAd.placementID];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded ad (%@) failed to load with error: %@", rewardedVideoAd.placementID, adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden: %@", rewardedVideoAd.placementID];
    [self.delegate didHideRewardedAd];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded ad clicked: %@", rewardedVideoAd.placementID];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video completed: %@", rewardedVideoAd.placementID];
    
    self.grantedReward = YES;
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    [self.parentAdapter log: @"Rewarded video started: %@", rewardedVideoAd.placementID];
    
    [self.delegate didDisplayRewardedAd];
}

@end

@implementation ALFacebookMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.format = format;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    [self.parentAdapter log: @"Banner loaded: %@", adView.placementID];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Banner (%@) failed to load with error: %@", adView.placementID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    [self.parentAdapter log: @"Banner shown: %@", adView.placementID];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    [self.parentAdapter log: @"Banner clicked: %@", adView.placementID];
    [self.delegate didClickAdViewAd];
    [self.delegate didExpandAdViewAd];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    [self.parentAdapter log: @"Banner finished handling click: %@", adView.placementID];
    [self.delegate didCollapseAdViewAd];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation ALFacebookMediationAdapterNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.format = format;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ loaded: %@", self.format.label, nativeAd.placementID];
    
    // `nativeAdViewAd` may be nil if the adapter is destroyed before the ad loaded (timed out).
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter log: @"Native %@ failed to load: no fill", self.format.label];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![self.parentAdapter.nativeAd isAdValid] )
    {
        [self.parentAdapter log: @"Native %@ failed to load: ad is no longer valid", self.format.label];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.adExpiredError];
        
        return;
    }
    
    if ( self.format != MAAdFormat.mrec ) // Native banners and leaders use APIs
    {
        [self renderNativeAdView];
    }
    else
    {
        FBNativeAdView *adView = [FBNativeAdView nativeAdViewWithNativeAd: self.parentAdapter.nativeAd];
        [self.delegate didLoadAdForAdView: adView];
    }
}

- (void)nativeAdDidDownloadMedia:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ (%@) successfully downloaded media", self.format.label, nativeAd.placementID];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ (%@) failed to load with error: %@", self.format.label, nativeAd.placementID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ shown: %@", self.format.label, nativeAd.placementID];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ clicked: %@", self.format.label, nativeAd.placementID];
    [self.delegate didClickAdViewAd];
    [self.delegate didExpandAdViewAd];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ finished handling click: %@", self.format.label, nativeAd.placementID];
    [self.delegate didCollapseAdViewAd];
}

- (void)renderNativeAdView
{
    // Ensure UI rendering is done on main queue
    dispatchOnMainQueue(^{
        FBMediaView *iconView = [[FBMediaView alloc] init];
        FBMediaView *mediaView = [[FBMediaView alloc] init];
        
        MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.format builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = self.parentAdapter.nativeAd.headline;
            builder.advertiser = self.parentAdapter.nativeAd.advertiserName;
            builder.body = self.parentAdapter.nativeAd.bodyText;
            builder.callToAction = self.parentAdapter.nativeAd.callToAction;
            builder.iconView = iconView;
            builder.mediaView = mediaView;
            
            FBAdOptionsView *adOptionsView = [[FBAdOptionsView alloc] init];
            adOptionsView.nativeAd = self.parentAdapter.nativeAd;
            adOptionsView.backgroundColor = UIColor.clearColor;
            builder.optionsView = adOptionsView;
        }];
        
        // Backend will pass down `vertical` as the template to indicate using a vertical native template
        MANativeAdView *maxNativeAdView;
        NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
        if ( [templateName containsString: @"vertical"] )
        {
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( self.format == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
            }
        }
        else
        {
            maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: [templateName al_isValidString] ? templateName : @"media_banner_template"];
        }
        
        NSMutableArray *clickableViews = [NSMutableArray array];
        
        if ( [maxNativeAd.title al_isValidString] && maxNativeAdView.titleLabel )
        {
            [clickableViews addObject: maxNativeAdView.titleLabel];
        }
        if ( [maxNativeAd.body al_isValidString] && maxNativeAdView.bodyLabel )
        {
            [clickableViews addObject: maxNativeAdView.bodyLabel];
        }
        if ( [maxNativeAd.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
        {
            [clickableViews addObject: maxNativeAdView.callToActionButton];
        }
        if ( maxNativeAd.iconView )
        {
            [clickableViews addObject: maxNativeAd.iconView];
        }
        if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
        {
            [clickableViews addObject: maxNativeAdView.mediaContentView];
        }
        if ( [maxNativeAd.advertiser al_isValidString] && maxNativeAdView.advertiserLabel )
        {
            [clickableViews addObject: maxNativeAdView.advertiserLabel];
        }
        
        [self.parentAdapter.nativeAd registerViewForInteraction: maxNativeAdView
                                                      mediaView: mediaView
                                                       iconView: iconView
                                                 viewController: [ALUtils topViewControllerFromKeyWindow]
                                                 clickableViews: clickableViews];
        
        [self.delegate didLoadAdForAdView: maxNativeAdView];
    });
}

@end

@implementation ALFacebookMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded: %@", nativeAd.placementID];
    [self.parentAdapter renderTrueNativeAd: nativeAd
                          serverParameters: self.serverParameters
                                 andNotify: self.delegate];
}

- (void)nativeAdDidDownloadMedia:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad (%@) successfully downloaded media", nativeAd.placementID];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", nativeAd.placementID, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown: %@", nativeAd.placementID];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked: %@", nativeAd.placementID];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad finished handling click: %@", nativeAd.placementID];
}

@end

@implementation ALFacebookMediationAdapterNativeBannerAdDelegate

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.serverParameters = serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd
{
    [self.parentAdapter log: @"Native banner ad loaded: %@", nativeBannerAd.placementID];
    [self.parentAdapter renderTrueNativeAd: nativeBannerAd
                          serverParameters: self.serverParameters
                                 andNotify: self.delegate];
}

- (void)nativeBannerAdDidDownloadMedia:(FBNativeBannerAd *)nativeBannerAd
{
    [self.parentAdapter log: @"Native banner ad (%@) successfully downloaded media", nativeBannerAd.placementID];
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALFacebookMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native banner ad (%@) failed to load with error: %@", nativeBannerAd.placementID, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeBannerAdWillLogImpression:(FBNativeBannerAd *)nativeBannerAd
{
    [self.parentAdapter log: @"Native banner ad shown: %@", nativeBannerAd.placementID];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeBannerAdDidClick:(FBNativeBannerAd *)nativeBannerAd
{
    [self.parentAdapter log: @"Native banner ad clicked: %@", nativeBannerAd.placementID];
    [self.delegate didClickNativeAd];
}

- (void)nativeBannerAdDidFinishHandlingClick:(FBNativeBannerAd *)nativeBannerAd
{
    [self.parentAdapter log: @"Native banner ad finished handling click: %@", nativeBannerAd.placementID];
}

@end

@implementation MAFacebookNativeAd

- (instancetype)initWithParentAdapter:(ALFacebookMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    FBNativeAd *nativeAd = self.parentAdapter.nativeAd;
    FBNativeBannerAd *nativeBannerAd = self.parentAdapter.nativeBannerAd;
    if ( !nativeAd && !nativeBannerAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    NSMutableArray *facebookClickableViews = [NSMutableArray array];
    [facebookClickableViews addObjectsFromArray: clickableViews];
    [facebookClickableViews addObject: self.mediaView]; // mediaView needs to be in the clickableViews for the mediaView to be clickable even though it is only a container of the network's media view
    
    UIImageView *iconImageView;
    if ( [container isKindOfClass: [MANativeAdView class]] ) // Native integrations
    {
        iconImageView = ((MANativeAdView *) container).iconImageView;
    }
    else // Plugins
    {
        for ( UIView *clickableView in clickableViews )
        {
            if ( clickableView.tag == ICON_VIEW_TAG )
            {
                iconImageView = (UIImageView *) clickableView;
                break;
            }
        }
    }
    
    if ( self.parentAdapter.nativeBannerAd )
    {
        if ( iconImageView )
        {
            [self.parentAdapter.nativeBannerAd registerViewForInteraction: container
                                                            iconImageView: iconImageView
                                                           viewController: [ALUtils topViewControllerFromKeyWindow]
                                                           clickableViews: facebookClickableViews];
        }
        else if ( self.mediaView )
        {
            [self.parentAdapter.nativeBannerAd registerViewForInteraction: container
                                                            iconImageView: (UIImageView *) self.mediaView
                                                           viewController: [ALUtils topViewControllerFromKeyWindow]
                                                           clickableViews: facebookClickableViews];
        }
        else
        {
            [self.parentAdapter e: @"Failed to register native ad view for interaction: icon image view and media view are nil"];
            return NO;
        }
        
        // Facebook sets the content mode for the media view to be aspect fill, so we need to reset it for true native banner media views.
        self.mediaView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        [self.parentAdapter.nativeAd registerViewForInteraction: container
                                                      mediaView: (FBMediaView *) self.mediaView
                                                  iconImageView: iconImageView
                                                 viewController: [ALUtils topViewControllerFromKeyWindow]
                                                 clickableViews: facebookClickableViews];
    }
    
    return YES;
}

@end
