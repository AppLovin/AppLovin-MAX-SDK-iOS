//
//  ALCriteoMediationAdapter.m
//  AppLovinSDK
//
//  Created by Vu on 01/12/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALCriteoMediationAdapter.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

#define ADAPTER_VERSION @"4.5.0.0"
#define PUB_ID_KEY @"pub_id"

@interface ALCriteoInterstitialDelegate : NSObject<CRInterstitialDelegate>
@property (nonatomic, weak) ALCriteoMediationAdapter *parentAdapter;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALCriteoAdViewDelegate : NSObject<CRBannerViewDelegate>
@property (nonatomic, weak) ALCriteoMediationAdapter *parentAdapter;
@property (nonatomic, weak) MAAdFormat *adFormat;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALCriteoNativeDelegate : NSObject<CRNativeLoaderDelegate>
@property (nonatomic, weak) ALCriteoMediationAdapter *parentAdapter;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MACriteoNativeAd : MANativeAd
@property (nonatomic, weak) ALCriteoMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALCriteoMediationAdapter()
@property (nonatomic, strong) CRBannerView *bannerAd;
@property (nonatomic, strong) ALCriteoAdViewDelegate *bannerAdDelegate;

@property (nonatomic, strong) CRInterstitial *interstitialAd;
@property (nonatomic, strong) ALCriteoInterstitialDelegate *interstitialAdDelegate;

@property (nonatomic, strong) CRNativeAd *nativeAd;
@property (nonatomic, strong) CRNativeLoader *nativeAdLoader;
@property (nonatomic, strong) CRNativeAdView *nativeAdView;
@property (nonatomic, strong) ALCriteoNativeDelegate *nativeAdAdapterDelegate;
@end

@implementation ALCriteoMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;
static ALAtomicBoolean *ALCriteoInitialized;
static MAAdapterInitializationStatus ALCriteoInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALCriteoInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    [self log: @"Initializing Criteo SDK..."];
    
    if ( [ALCriteoInitialized compareAndSet: NO update: YES] )
    {
        ALCriteoInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        // Criteo requires a valid publisher key for initialization
        NSString *publisherKey = parameters.serverParameters[PUB_ID_KEY];
        if ( ![publisherKey al_isValidString] )
        {
            [self log: @"Criteo failed to initialize because the publisher key is missing."];
            
            ALCriteoInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            completionHandler(ALCriteoInitializationStatus, @"Criteo failed to initialize because the publisher key is missing.");
            
            return;
        }
        
        [Criteo setVerboseLogsEnabled: [parameters isTesting]];
        [[Criteo sharedCriteo] registerCriteoPublisherId: publisherKey withAdUnits: @[]];
        
        ALCriteoInitializationStatus = MAAdapterInitializationStatusInitializedUnknown;
    }
    
    completionHandler(ALCriteoInitializationStatus, nil);
}

- (NSString *)SDKVersion
{
    return [NSString stringWithFormat: @"%ld", (long) CRITEO_PUBLISHER_SDK_VERSION];
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
    self.interstitialAdDelegate = nil;
    
    self.bannerAd.delegate = nil;
    self.bannerAd = nil;
    self.bannerAdDelegate = nil;
    
    self.nativeAdLoader.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdView = nil;
    self.nativeAdLoader = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self updatePrivacySettings: parameters];
    
    [delegate didCollectSignal: @""]; // No-op since Criteo does not need the buyeruid to bid
}

#pragma mark - MAInterstitialAdpater Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    
    [self log: @"Loading %@interstitial ad: %@...", ( isBiddingAd ? @"bidding " : @"" ), placementIdentifier];
    
    [self updatePrivacySettings: parameters];
    
    CRInterstitialAdUnit *interstitialAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId: placementIdentifier];
    self.interstitialAd = [[CRInterstitial alloc] initWithAdUnit: interstitialAdUnit];
    self.interstitialAdDelegate = [[ALCriteoInterstitialDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    [self.interstitialAd loadAdWithDisplayData: parameters.bidResponse];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", placementIdentifier];
    
    if ( [self.interstitialAd isAdLoaded] )
    {
        [self.interstitialAd presentFromRootViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad failed to show: %@", placementIdentifier];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBiddingAd = [parameters.bidResponse al_isValidString];
    
    [self log: @"Loading %@%@ ad: %@...", ( isBiddingAd ? @"bidding " : @""), adFormat.label, placementIdentifier];
    
    [self updatePrivacySettings: parameters];
    
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId: placementIdentifier size: adFormat.size];
    self.bannerAd = [[CRBannerView alloc] initWithAdUnit: bannerAdUnit];
    self.bannerAdDelegate = [[ALCriteoAdViewDelegate alloc] initWithParentAdapter: self adFormat:adFormat placementIdentifier: placementIdentifier andNotify: delegate];
    self.bannerAd.delegate = self.bannerAdDelegate;
    [self.bannerAd loadAdWithDisplayData: parameters.bidResponse];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *placementIdentifier = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Loading native ad: %@...", placementIdentifier];
    
    [self updatePrivacySettings: parameters];
    
    CRNativeAdUnit *nativeAdUnit = [[CRNativeAdUnit alloc] initWithAdUnitId: placementIdentifier];
    self.nativeAdLoader = [[CRNativeLoader alloc] initWithAdUnit: nativeAdUnit];
    
    self.nativeAdAdapterDelegate = [[ALCriteoNativeDelegate alloc] initWithParentAdapter: self placementIdentifier: placementIdentifier parameters: parameters andNotify: delegate];
    self.nativeAdLoader.delegate = self.nativeAdAdapterDelegate;
    [self.nativeAdLoader loadAd];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)criteoError
{
    NSInteger criteoErrorCode = criteoError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    /* Based on the current order as defined in NSError+Criteo.h (which isn't exposed):
     typedef NS_ENUM(NSInteger, CRErrorCode) {
     CRErrorCodeInternalError,
     CRErrorCodeNoFill,
     CRErrorCodeNetworkError,
     CRErrorCodeInvalidRequest,
     CRErrorCodeInvalidParameter,
     CRErrorCodeInvalidErrorCode
     };
     */
    switch ( criteoErrorCode )
    {
        case 0:
            adapterError = MAAdapterError.internalError;
            break;
        case 1:
            adapterError = MAAdapterError.noFill;
            break;
        case 2:
            adapterError = MAAdapterError.noConnection;
            break;
        case 3:
            adapterError = MAAdapterError.badRequest;
            break;
        case 4:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 5:
            adapterError = MAAdapterError.unspecified;
    }
    
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                  thirdPartySdkErrorCode: criteoErrorCode
               thirdPartySdkErrorMessage: criteoError.localizedDescription];
}

- (void)updatePrivacySettings:(id<MAAdapterParameters>)parameters
{
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        NSNumber *hasUserConsent = parameters.hasUserConsent;
        if ( hasUserConsent )
        {
            [[Criteo sharedCriteo] setUsPrivacyOptOut: !hasUserConsent.boolValue];
        }
    }
}

@end

@implementation ALCriteoInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded: %@", self.placementIdentifier];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALCriteoMediationAdapter toMaxError: error];
    
    [self.parentAdapter log: @"Interstitial ad (%@) failed to load with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will appear: %@", self.placementIdentifier];
}

- (void)interstitialDidAppear:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad did track impression: %@", self.placementIdentifier];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will leave application: %@", self.placementIdentifier];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad will disappear: %@", self.placementIdentifier];
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALCriteoAdViewDelegate

- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, self.placementIdentifier];
    
    [self.delegate didLoadAdForAdView: bannerView];
    [self.delegate didDisplayAdViewAd]; // Criteo does not have a dedicated impression callback
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALCriteoMediationAdapter toMaxError: error];
    
    [self.parentAdapter log: @"%@ ad (%@) failed to load with error: %@", self.adFormat.label, self.placementIdentifier, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, self.placementIdentifier];
    [self.delegate didClickAdViewAd];
}

@end

@implementation ALCriteoNativeDelegate

- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
    }
    return self;
}

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad
{
    self.parentAdapter.nativeAd = ad;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    
    if ( ![self hasRequiredAssetsInAd: ad isTemplateAd: isTemplateAd] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", ad];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError missingRequiredNativeAdAssets]];
        
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    __block MANativeAdImage *iconImage = nil;
    if ( ad.advertiserLogoMedia.url )
    {
        NSURL *iconImageURL = ad.advertiserLogoMedia.url;
        
        [self.parentAdapter log: @"Fetching native ad icon: %@", iconImageURL];
        [self loadImageForURL: iconImageURL group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    __block UIView *mediaView;
    if ( ad.productMedia.url )
    {
        NSURL *mainImageURL = ad.productMedia.url;
        
        [self.parentAdapter log: @"Fetching native ad media: %@", mainImageURL];
        [self loadImageForURL: mainImageURL group: group successHandler:^(UIImage *image) {
            mediaView = [[UIImageView alloc] initWithImage: image];
            mediaView.contentMode = UIViewContentModeScaleAspectFit;
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        dispatchOnMainQueue(^{
            // Media view is required for non-template native ads.
            if ( !isTemplateAd && !mediaView )
            {
                [self.parentAdapter e: @"Media view asset is null for native custom ad view. Failing ad request."];
                [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError missingRequiredNativeAdAssets]];
                
                return;
            }
            
            MANativeAd *maxNativeAd = [[MACriteoNativeAd alloc] initWithParentAdapter: self.parentAdapter builderBlock:^(MANativeAdBuilder *builder) {
                builder.icon = iconImage;
                builder.title = ad.title;
                builder.advertiser = ad.advertiserDomain;
                builder.body = ad.body;
                builder.mediaView = mediaView;
                builder.callToAction = ad.callToAction;
            }];
            
            [self.parentAdapter log: @"Native ad loaded: %@", self.placementIdentifier];
            [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
        });
    });
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALCriteoMediationAdapter toMaxError: error];
    
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeLoaderWillLeaveApplication:(CRNativeLoader *)loader
{
    [self.parentAdapter log: @"Native ad will leave application"];
}

- (void)loadImageForURL:(NSURL *)URL group:(dispatch_group_t)group successHandler:(void (^)(UIImage *image))successHandler;
{
    // Criteo's image resources come in the form of URLs that need to be fetched in a non-blocking manner
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_group_enter(group);
        
        [[[NSURLSession sharedSession] dataTaskWithURL: URL
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if ( error )
            {
                [self.parentAdapter log: @"Failed to fetch native ad image URL (%@) with error: %@", [URL absoluteString], error];
            }
            else if ( data )
            {
                [self.parentAdapter log: @"Native ad image data retrieved"];
                
                UIImage *image = [UIImage imageWithData: data];
                if ( image )
                {
                    // Run on main queue for convenient image view updates
                    dispatchOnMainQueue(^{
                        successHandler(image);
                    });
                }
            }
            
            // Don't consider the block done until this task is complete
            dispatch_group_leave(group);
        }] resume];
    });
}

- (BOOL)hasRequiredAssetsInAd:(CRNativeAd *)nativeAd isTemplateAd:(BOOL)isTemplateAd
{
    if ( isTemplateAd )
    {
        return [nativeAd.title al_isValidString];
    }
    else
    {
        // NOTE: Media view is required and is checked separately.
        return [nativeAd.title al_isValidString]
        && [nativeAd.callToAction al_isValidString];
    }
}

@end

@implementation MACriteoNativeAd

- (instancetype)initWithParentAdapter:(ALCriteoMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    if ( !self.parentAdapter.nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad view: native ad is nil."];
        return;
    }
    
    self.parentAdapter.nativeAdView = [[CRNativeAdView alloc] init];
    self.parentAdapter.nativeAdView.nativeAd = self.parentAdapter.nativeAd;
    
    [maxNativeAdView addSubview: self.parentAdapter.nativeAdView];
    
    // Pin view to activate impression and click tracking
    [self.parentAdapter.nativeAdView al_pinToSuperview];
}

@end
