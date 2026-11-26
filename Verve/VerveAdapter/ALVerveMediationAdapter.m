//
//  ALVerveMediationAdapter.m
//  AppLovinSDK
//
//  Created by Ashley on 7/30/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALVerveMediationAdapter.h"
#import <HyBid/HyBid.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
#import <HyBid/HyBid-Swift.h>
#else
#import "HyBid-Swift.h"
#endif

#define ADAPTER_VERSION @"3.9.3.0"
#define DEFAULT_IMAGE_TASK_TIMEOUT_SECONDS 10.0

@interface ALVerveMediationAdapterInterstitialAdDelegate : NSObject <HyBidInterstitialAdDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapterRewardedAdsDelegate : NSObject <HyBidRewardedAdDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapterAdViewDelegate : NSObject <HyBidAdViewDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALVerveMediationAdapterNativeAdDelegate : NSObject <HyBidNativeAdLoaderDelegate, HyBidNativeAdDelegate>
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAVerveNativeAd : MANativeAd
@property (nonatomic, weak) ALVerveMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALVerveMediationAdapter ()

// Interstitial
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALVerveMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;

// Rewarded
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (nonatomic, strong) ALVerveMediationAdapterRewardedAdsDelegate *rewardedAdapterDelegate;

// AdView
@property (nonatomic, strong) HyBidAdView *adViewAd;
@property (nonatomic, strong) ALVerveMediationAdapterAdViewDelegate *adViewAdapterDelegate;

// Native
@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) HyBidNativeAd *nativeAd;
@property (nonatomic, strong) ALVerveMediationAdapterNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALVerveMediationAdapter
static ALAtomicBoolean *ALVerveInitialized;
static MAAdapterInitializationStatus ALVerveInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALVerveInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALVerveInitialized compareAndSet: NO update: YES] )
    {
        ALVerveInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *appToken = [parameters.serverParameters al_stringForKey: @"app_token" defaultValue: @""];
        [self log: @"Initializing Verve SDK with app token: %@...", appToken];
        
        if ( [parameters isTesting] )
        {
            [HyBid setTestMode: YES];
            [HyBidLogger setLogLevel: HyBidLogLevelDebug];
        }
        
        [HyBid initWithAppToken: appToken completion:^(BOOL success) {
            if ( success )
            {
                [self log: @"Verve SDK initialized"];
                ALVerveInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            }
            else
            {
                [self log: @"Verve SDK failed to initialize"];
                ALVerveInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            }
            
            completionHandler(ALVerveInitializationStatus, nil);
        }];
    }
    else
    {
        completionHandler(ALVerveInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [HyBid getSDKVersionInfo];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    self.interstitialAdapterDelegate.delegate = nil;
    self.interstitialAdapterDelegate = nil;
    self.interstitialAd = nil;
    
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    self.rewardedAd = nil;
    
    self.adViewAd.delegate = nil;
    self.adViewAd = nil;
    
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;

    // stopTracking removes gesture recognizers and finishes the OM session, both need main
    HyBidNativeAd *nativeAd = self.nativeAd;
    dispatchOnMainQueue(^{
        [nativeAd stopTracking];
    });
    self.nativeAd = nil;
    self.nativeAdLoader = nil;

    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    // Update local params, since not available on init
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    
    NSString *signal = [HyBid getCustomRequestSignalData];
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdpater Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad"];
    
    if ( ![HyBid isInitialized] )
    {
        [self log: @"Verve SDK is not initialized: failing interstitial ad load..."];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    
    self.interstitialAdapterDelegate = [[ALVerveMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithDelegate: self.interstitialAdapterDelegate];
    
    [self.interstitialAd prepareAdWithContent: parameters.bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialAd isReady] )
    {
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.interstitialAd showFromViewController: presentingViewController];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
    }
}

#pragma mark - MARewardAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad"];
    
    if ( ![HyBid isInitialized] )
    {
        [self log: @"Verve SDK is not initialized: failing rewarded ad load..."];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    
    self.rewardedAdapterDelegate = [[ALVerveMediationAdapterRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithDelegate: self.rewardedAdapterDelegate];
    
    [self.rewardedAd prepareAdWithContent: parameters.bidResponse];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedAd isReady] )
    {
        [self configureRewardForParameters: parameters];
        
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.rewardedAd showFromViewController: presentingViewController];
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

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad view ad...", adFormat.label];
    
    if ( ![HyBid isInitialized] )
    {
        [self log: @"Verve SDK is not initialized: failing %@ ad load...", adFormat.label];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.notInitialized];
        
        return;
    }
    
    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];
    
    self.adViewAd = [[HyBidAdView alloc] initWithSize: [self sizeFromAdFormat: adFormat]];
    self.adViewAdapterDelegate = [[ALVerveMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.adViewAd.delegate = self.adViewAdapterDelegate;
    
    [self.adViewAd renderAdWithContent: parameters.bidResponse withDelegate: self.adViewAdapterDelegate];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad..."];

    if ( ![HyBid isInitialized] )
    {
        [self log: @"Verve SDK is not initialized: failing native ad load..."];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.notInitialized];

        return;
    }

    [self updateLocationCollectionEnabled: parameters];
    [self updateConsentWithParameters: parameters];

    self.nativeAdAdapterDelegate = [[ALVerveMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                        serverParameters: parameters.serverParameters
                                                                                               andNotify: delegate];
    self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];

    // The bid response is HyBid's signal data envelope, as for the other formats
    [self.nativeAdLoader prepareNativeAdWithDelegate: self.nativeAdAdapterDelegate withContent: parameters.bidResponse];
}

#pragma mark - Shared Methods

- (void)updateLocationCollectionEnabled:(id<MAAdapterParameters>)parameters
{
    NSDictionary<NSString *, id> *localExtraParameters = parameters.localExtraParameters;
    NSNumber *isLocationCollectionEnabled = [localExtraParameters al_numberForKey: @"is_location_collection_enabled"];
    if ( isLocationCollectionEnabled != nil )
    {
        // NOTE: iOS disables by defualt, whereas Android enables by default
        [HyBid setLocationUpdates: isLocationCollectionEnabled.boolValue];
    }
}

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    // From PubNative: "HyBid SDK is TCF v2 compliant, so any change in the IAB consent string will be picked up by the SDK."
    // Because of this, they requested that we don't update consent values if one is already set and use binary consent state as a fallback.
    // As a side effect, pubs that use the MAX consent flow will not be able to update consent values mid-session.
    // Full context in this PR: https://github.com/AppLovin/AppLovin-MAX-SDK-iOS/pull/57
    
    NSNumber *hasUserConsent = parameters.hasUserConsent;
    if ( hasUserConsent != nil )
    {
        // NOTE: verveGDPRConsentString can be nil, TCFv2 consent string, "1" or "0"
        NSString *verveGDPRConsentString = [[HyBidUserDataManager sharedInstance] getIABGDPRConsentString];
        
        // If hasUserConsent is set to false, set consent string to "0"
        if ( !hasUserConsent.boolValue )
        {
            [[HyBidUserDataManager sharedInstance] setIABGDPRConsentString: @"0"];
        }
        // If hasUserConsent is set to true, only override if it has not been set to a TCFv2 consent string or is set to "0"
        else if ( ![verveGDPRConsentString al_isValidString] || [verveGDPRConsentString isEqualToString: @"0"] )
        {
            [[HyBidUserDataManager sharedInstance] setIABGDPRConsentString: @"1"];
        }
    }
    
    NSString *verveUSPrivacyString = [[HyBidUserDataManager sharedInstance] getIABUSPrivacyString];
    if ( !verveUSPrivacyString || [verveUSPrivacyString isEqualToString: @""] )
    {
        NSNumber *isDoNotSell = parameters.doNotSell;
        if ( isDoNotSell && isDoNotSell.boolValue )
        {
            // NOTE: PubNative suggested this US Privacy String, so it does not match other adapters.
            [[HyBidUserDataManager sharedInstance] setIABUSPrivacyString: @"1NYN"];
        }
    }
}

- (HyBidAdSize *)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return HyBidAdSize.SIZE_320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return HyBidAdSize.SIZE_728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return HyBidAdSize.SIZE_300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return HyBidAdSize.SIZE_320x50;
    }
}

+ (MAAdapterError *)toMaxError:(NSError *)verveError
{
    NSInteger verveErrorCode = verveError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( verveErrorCode )
    {
        case 1: // No Fill
        case 6: // Null Ad
            adapterError = MAAdapterError.noFill;
            break;
        case 2: // Parse Error
        case 3: // Server Error
            adapterError = MAAdapterError.serverError;
            break;
        case 4: // Invalid Asset
        case 5: // Unsupported Asset
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 7: // Invalid Ad
        case 8: // Invalid Zone ID
        case 9: // Invalid Signal Data
            adapterError = MAAdapterError.badRequest;
            break;
        case 10: // Not Initialized
            adapterError = MAAdapterError.notInitialized;
            break;
        case 11: // Auction No Ad
        case 12: // Rendering Banner
        case 13: // Rendering Interstitial
        case 14: // Rendering Rewarded
            adapterError = MAAdapterError.adNotReady;
            break;
        case 15: // Mraid Player
        case 16: // Vast Player
        case 17: // Tracking URL
        case 18: // Tracking JS
        case 19: // Invalid URL
        case 20: // Internal
            adapterError = MAAdapterError.internalError;
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: verveErrorCode
                     mediatedNetworkErrorMessage: verveError.localizedDescription];
}

@end

@implementation ALVerveMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidLoad
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidTrackImpression
{
    [self.parentAdapter log: @"Interstitial did track impression"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialDidTrackClick
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialDidDismiss
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALVerveMediationAdapterRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewardedDidLoad
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedDidTrackImpression
{
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedDidTrackClick
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)onReward
{
    [self.parentAdapter log: @"Rewarded ad reward granted"];
    self.grantedReward = YES;
}

- (void)rewardedDidDismiss
{
    [self.parentAdapter log: @"Rewarded ad did disappear"];
    
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

@implementation ALVerveMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adViewDidLoad:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView ad loaded"];
    [self.delegate didLoadAdForAdView: adView];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"AdView failed to load: %@", error];
    
    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView did track impression: %@", adView];
    [self.delegate didDisplayAdViewAd];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView
{
    [self.parentAdapter log: @"AdView clicked: %@", adView];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALVerveMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd
{
    if ( !nativeAd )
    {
        [self.parentAdapter log: @"Native ad failed to load: no fill"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];

        return;
    }

    [self.parentAdapter log: @"Native ad loaded"];
    self.parentAdapter.nativeAd = nativeAd;

    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.title al_isValidString] )
    {
        [self.parentAdapter log: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];

        return;
    }

    // Same as the other MAX adapters: the images are downloaded here, and an image that can't be downloaded is left out
    // instead of failing the ad. A text only ad has nothing to download.
    dispatch_group_t group = dispatch_group_create();
    NSMutableDictionary<NSString *, UIImage *> *images = [NSMutableDictionary dictionary];
    if ( [nativeAd.iconUrl al_isValidURL] )
    {
        [self loadImageForURLString: nativeAd.iconUrl key: @"icon" into: images group: group];
    }
    if ( [nativeAd.bannerUrl al_isValidURL] )
    {
        [self loadImageForURLString: nativeAd.bannerUrl key: @"main" into: images group: group];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimeInterval timeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(DEFAULT_IMAGE_TASK_TIMEOUT_SECONDS)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeoutSeconds * NSEC_PER_SEC)));

        UIImage *iconImage;
        UIImage *mainImage;
        @synchronized ( images )
        {
            iconImage = images[@"icon"];
            mainImage = images[@"main"];
        }
        [self processNativeAd: nativeAd iconImage: iconImage mainImage: mainImage];
    });
}

- (void)loadImageForURLString:(NSString *)urlString key:(NSString *)key into:(NSMutableDictionary<NSString *, UIImage *> *)images group:(dispatch_group_t)group
{
    dispatch_group_enter(group);
    [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: urlString]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data ? [UIImage imageWithData: data] : nil;
        if ( image )
        {
            @synchronized ( images )
            {
                images[key] = image;
            }
        }
        else
        {
            [self.parentAdapter log: @"Native ad image (%@) could not be downloaded, loading the ad without it: %@", key, error];
        }
        dispatch_group_leave(group);
    }] resume];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Native ad failed to load: %@", error];

    MAAdapterError *adapterError = [ALVerveMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)processNativeAd:(HyBidNativeAd *)nativeAd iconImage:(UIImage *)iconImage mainImage:(UIImage *)mainImage
{
    dispatchOnMainQueue(^{
        MANativeAd *maxNativeAd = [[MAVerveNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.body = nativeAd.body;
            builder.callToAction = nativeAd.callToActionTitle;
            builder.starRating = nativeAd.rating;

            if ( iconImage )
            {
                builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
            }

            if ( mainImage )
            {
                UIImageView *mainImageView = [[UIImageView alloc] initWithImage: mainImage];
                mainImageView.contentMode = UIViewContentModeScaleAspectFit;
                builder.mediaView = mainImageView;
                builder.mainImage = [[MANativeAdImage alloc] initWithImage: mainImage];
            }

            if ( nativeAd.contentInfo )
            {
                builder.optionsView = nativeAd.contentInfo;
            }
        }];

        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view
{
    [self.parentAdapter log: @"Native ad did track impression"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

@end

@implementation MAVerveNativeAd

- (instancetype)initWithParentAdapter:(ALVerveMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    HyBidNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter log: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }

    // HyBid falls back to the container only for nil, an empty list would leave nothing clickable
    NSArray<UIView *> *views = clickableViews.count > 0 ? clickableViews : nil;
    [nativeAd startTrackingView: container withClickableViews: views withDelegate: self.parentAdapter.nativeAdAdapterDelegate];

    return YES;
}

@end
