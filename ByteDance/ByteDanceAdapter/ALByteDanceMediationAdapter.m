//
//  ALByteDanceMediationAdapter.m
//  Adapters
//
//  Created by Thomas So on 12/25/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALByteDanceMediationAdapter.h"
#import <PAGAdSDK/PAGAdSDK.h>

#define ADAPTER_VERSION @"5.4.0.8.0"

@interface ALByteDanceInterstitialAdDelegate : NSObject <PAGLInterstitialAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALByteDanceAppOpenAdDelegate : NSObject <PAGLAppOpenAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAppOpenAdapterDelegate>)delegate;
@end

@interface ALByteDanceRewardedVideoAdDelegate : NSObject <PAGRewardedAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALByteDanceAdViewAdDelegate : NSObject <PAGBannerAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALByteDanceNativeAdViewAdDelegate : NSObject <PAGLNativeAdDelegate>
@property (nonatomic,   weak) MAAdFormat *adFormat;
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALByteDanceNativeAdDelegate : NSObject <PAGLNativeAdDelegate>
@property (nonatomic,   weak) ALByteDanceMediationAdapter *parentAdapter;
@property (nonatomic,   copy) NSString *slotId;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MAPangleNativeAd : MANativeAd
@property (nonatomic, weak) ALByteDanceMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALByteDanceMediationAdapter ()

@property (nonatomic, strong) PAGLInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALByteDanceInterstitialAdDelegate *interstitialAdDelegate;

@property (nonatomic, strong) PAGLAppOpenAd *appOpenAd;
@property (nonatomic, strong) ALByteDanceAppOpenAdDelegate *appOpenAdDelegate;

@property (nonatomic, strong) PAGRewardedAd *rewardedVideoAd;
@property (nonatomic, strong) ALByteDanceRewardedVideoAdDelegate *rewardedVideoAdDelegate;

@property (nonatomic, strong) PAGBannerAd *adViewAd;
@property (nonatomic, strong) ALByteDanceAdViewAdDelegate *adViewAdDelegate;
@property (nonatomic, strong) PAGLNativeAd *nativeAdViewAd;
@property (nonatomic, strong) ALByteDanceNativeAdViewAdDelegate *nativeAdViewAdDelegate;
@property (nonatomic, strong) PAGLNativeAdRelatedView *nativeAdViewRelatedView;

@property (nonatomic, strong) PAGLNativeAd *nativeAd;
@property (nonatomic, strong) ALByteDanceNativeAdDelegate *nativeAdDelegate;
@property (nonatomic, strong) PAGLNativeAdRelatedView *nativeAdRelatedView;

@end

@implementation ALByteDanceMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;
static ALAtomicBoolean              *ALByteDanceInitialized;
static MAAdapterInitializationStatus ALByteDanceInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALByteDanceInitialized = [[ALAtomicBoolean alloc] init];
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALByteDanceInitialized compareAndSet: NO update: YES] )
    {
        ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        PAGConfig *configuration = [PAGConfig shareConfig];
        configuration.userDataString = [self createUserDataStringWithParameters: parameters isInitializing: YES];
        
        NSString *appID = [parameters.serverParameters al_stringForKey: @"app_id"];
        [self log: @"Initializing Pangle SDK with app id: %@...", appID];
        configuration.appID = appID;
        
        UIImage *appIconImage = [self appIconImage];
        if ( !appIconImage )
        {
            [self log: @"App icon could not be found"];
        }
        else
        {
            configuration.appLogoImage = appIconImage;
        }
        
        if ( [parameters isTesting] )
        {
            configuration.debugLog = YES;
        }
        
        [self updateConsentWithParameters: parameters];
        
        [PAGSdk startWithConfig: configuration completionHandler:^(BOOL success, NSError *error) {
            if ( !success || error )
            {
                [self log: @"Pangle SDK failed to initialize with error: %@", error];
                
                ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALByteDanceInitializationStatus, error.localizedDescription);
                return;
            }
            
            [self log: @"Pangle SDK initialized"];
            
            ALByteDanceInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALByteDanceInitializationStatus, nil);
        }];
    }
    else
    {
        [self log: @"Pangle SDK already initialized"];
        completionHandler(ALByteDanceInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [PAGSdk SDKVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroying..."];
    
    self.interstitialAd.delegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate.delegate = nil;
    self.interstitialAdDelegate = nil;
    
    self.appOpenAd.delegate = nil;
    self.appOpenAd = nil;
    self.appOpenAdDelegate.delegate = nil;
    self.appOpenAdDelegate = nil;
    
    self.rewardedVideoAd.delegate = nil;
    self.rewardedVideoAd = nil;
    self.rewardedVideoAdDelegate.delegate = nil;
    self.rewardedVideoAdDelegate = nil;
    
    self.adViewAd.delegate = nil;
    self.adViewAd = nil;
    self.adViewAdDelegate.delegate = nil;
    self.adViewAdDelegate = nil;
    
    [self.nativeAdViewAd unregisterView];
    self.nativeAdViewAd.delegate = nil;
    self.nativeAdViewAd = nil;
    self.nativeAdViewAdDelegate.delegate = nil;
    self.nativeAdViewAdDelegate = nil;
    self.nativeAdViewRelatedView = nil;
    
    [self.nativeAd unregisterView];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
    self.nativeAdRelatedView = nil;
}

#pragma mark - Signal Collection

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateConsentWithParameters: parameters];
    
    NSString *signal = [PAGSdk getBiddingToken: nil];
    [delegate didCollectSignal: signal];
}

#pragma mark - Interstitial Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@interstitial ad for slot id \"%@\"...", isBidding ? @"bidding " : @"", slotId];
    
    [PAGConfig shareConfig].userDataString = [self createUserDataStringWithParameters: parameters isInitializing: NO];
    [self updateConsentWithParameters: parameters];
    
    PAGInterstitialRequest *request = [PAGInterstitialRequest request];
    
    if ( isBidding )
    {
        [request setAdString: bidResponse];
    }
    
    [PAGLInterstitialAd loadAdWithSlotID: slotId
                                 request: request
                       completionHandler:^(PAGLInterstitialAd *_Nullable ad, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
            [self log: @"Interstitial failed to load with error: %@", adapterError];
            
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !ad )
        {
            [self log: @"Interstitial ad (%@) NO FILL'd", slotId];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
            
            return;
        }
        
        [self log: @"Interstitial ad loaded: %@", slotId];
        
        self.interstitialAd = ad;
        
        self.interstitialAdDelegate = [[ALByteDanceInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.interstitialAd.delegate = self.interstitialAdDelegate;
        
        [delegate didLoadInterstitialAd];
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial..."];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.interstitialAd presentFromRootViewController: presentingViewController];
}

#pragma mark - App Open Ad Methods

- (void)loadAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@app open ad for slot id \"%@\"...", isBidding ? @"bidding " : @"", slotId];
    
    [PAGConfig shareConfig].userDataString = [self createUserDataStringWithParameters: parameters isInitializing: NO];
    [self updateConsentWithParameters: parameters];
    
    PAGAppOpenRequest *request = [PAGAppOpenRequest request];
    
    if ( isBidding )
    {
        [request setAdString: bidResponse];
    }
    
    [PAGLAppOpenAd loadAdWithSlotID: slotId request: request completionHandler:^(PAGLAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
        if ( error )
        {
            MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
            [self log: @"App Open ad failed to load with error: %@", adapterError];
            
            [delegate didFailToLoadAppOpenAdWithError: adapterError];
            
            return;
        }
        
        if ( !appOpenAd )
        {
            [self log: @"App Open ad (%@) NO FILL'd", slotId];
            [delegate didFailToLoadAppOpenAdWithError: MAAdapterError.noFill];
            
            return;
        }
        
        [self log: @"App Open ad loaded: %@", slotId];
        
        self.appOpenAd = appOpenAd;
        
        self.appOpenAdDelegate = [[ALByteDanceAppOpenAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.appOpenAd.delegate = self.appOpenAdDelegate;
        
        [delegate didLoadAppOpenAd];
    }];
}

- (void)showAppOpenAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    [self log: @"Showing app open ad..."];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.appOpenAd presentFromRootViewController: presentingViewController];
}

#pragma mark - Rewarded Ad Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@rewarded ad for slot id \"%@\"...", isBidding ? @"bidding " : @"", slotId];
    
    [PAGConfig shareConfig].userDataString = [self createUserDataStringWithParameters: parameters isInitializing: NO];
    [self updateConsentWithParameters: parameters];
    
    PAGRewardedRequest *request = [PAGRewardedRequest request];
    
    if ( isBidding )
    {
        [request setAdString: bidResponse];
    }
    
    [PAGRewardedAd loadAdWithSlotID: slotId
                            request: request
                  completionHandler:^(PAGRewardedAd *_Nullable ad, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
            [self log: @"Rewarded ad failed to load with error: %@", adapterError];
            
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            
            return;
        }
        
        if ( !ad )
        {
            [self log: @"Rewarded ad (%@) NO FILL'd", slotId];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
            
            return;
        }
        
        [self log: @"Rewarded ad loaded: %@", slotId];
        
        self.rewardedVideoAd = ad;
        
        self.rewardedVideoAdDelegate = [[ALByteDanceRewardedVideoAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
        self.rewardedVideoAd.delegate = self.rewardedVideoAdDelegate;
        
        [delegate didLoadRewardedAd];
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    // Configure reward from server.
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.rewardedVideoAd presentFromRootViewController: presentingViewController];
}

#pragma mark - AdView Ad Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@%@%@ ad for slot id \"%@\"...", isNative ? @"native " : @"", isBidding ? @"bidding " : @"", adFormat.label, slotId];
    
    [PAGConfig shareConfig].userDataString = [self createUserDataStringWithParameters: parameters isInitializing: NO];
    [self updateConsentWithParameters: parameters];
    
    dispatchOnMainQueue(^{
        
        if ( isNative )
        {
            PAGNativeRequest *request = [PAGNativeRequest request];
            
            if ( isBidding )
            {
                [request setAdString: bidResponse];
            }
            
            [PAGLNativeAd loadAdWithSlotID: slotId request: request completionHandler:^(PAGLNativeAd *_Nullable ad, NSError *_Nullable error) {
                
                if ( error )
                {
                    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
                    [self log: @"Native %@ (%@) failed to load with error: %@", adFormat.label, slotId, adapterError];
                    
                    [delegate didFailToLoadAdViewAdWithError: adapterError];
                    
                    return;
                }
                
                if ( !ad )
                {
                    [self log: @"Native ad view (%@) NO FILL'd", slotId];
                    [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
                    
                    return;
                }
                
                [self log: @"Native %@ ad loaded: %@. Preparing assets...", adFormat.label, slotId];
                
                self.nativeAdViewAd = ad;
                
                self.nativeAdViewAdDelegate = [[ALByteDanceNativeAdViewAdDelegate alloc] initWithParentAdapter: self
                                                                                                    parameters: parameters
                                                                                                        format: adFormat
                                                                                                     andNotify: delegate];
                self.nativeAdViewAd.delegate = self.nativeAdViewAdDelegate;
                
                PAGLMaterialMeta *nativeAdData = ad.data;
                
                // Run image fetching tasks asynchronously in the background
                dispatch_group_t group = dispatch_group_create();
                
                __block MANativeAdImage *iconImage = nil;
                if ( nativeAdData.icon && [nativeAdData.icon.imageURL al_isValidURL] )
                {
                    [self log: @"Fetching native ad icon: %@", nativeAdData.icon.imageURL];
                    [self loadImageForURLString: nativeAdData.icon.imageURL group: group successHandler:^(UIImage *image) {
                        iconImage = [[MANativeAdImage alloc] initWithImage: image];
                    }];
                }
                
                // Instantiate a relatedView and fill it based on the nativeAdViewAd
                self.nativeAdViewRelatedView = [[PAGLNativeAdRelatedView alloc] init];
                [self.nativeAdViewRelatedView refreshWithNativeAd: ad];
                
                UIView *optionsView = self.nativeAdViewRelatedView.logoADImageView;
                UIView *mediaView = self.nativeAdViewRelatedView.mediaView;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    // Timeout tasks if incomplete within the given time
                    NSTimeInterval imageTaskTimeoutSeconds = [[parameters.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
                    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
                    
                    // Create MANativeAd after images are loaded from remote URLs
                    dispatchOnMainQueue(^{
                        [self log: @"Creating native ad with assets"];
                        
                        // Currently we aren't rendering dislikeButton
                        // If we need it, we need to add it to the subView manually. It is accessible through relatedView
                        MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: adFormat builderBlock:^(MANativeAdBuilder *builder) {
                            builder.title = nativeAdData.AdTitle;
                            builder.body = nativeAdData.AdDescription;
                            builder.callToAction = nativeAdData.buttonText;
                            builder.icon = iconImage;
                            builder.optionsView = optionsView;
                            builder.mediaView = mediaView;
                        }];
                        
                        NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
                        MANativeAdView *maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
                        
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
                        if ( maxNativeAd.icon && maxNativeAdView.iconImageView )
                        {
                            [clickableViews addObject: maxNativeAdView.iconImageView];
                        }
                        if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
                        {
                            [clickableViews addObject: maxNativeAdView.mediaContentView];
                        }
                        
                        [ad registerContainer: maxNativeAdView withClickableViews: clickableViews];
                        
                        [self log: @"Native %@ ad fully loaded: %@", adFormat.label, slotId];
                        [delegate didLoadAdForAdView: maxNativeAdView];
                    });
                });
            }];
        }
        else
        {
            PAGBannerRequest *request = [PAGBannerRequest requestWithBannerSize: [self bannerAdSizeForAdFormat: adFormat]];
            
            if ( isBidding )
            {
                [request setAdString: bidResponse];
            }
            
            [PAGBannerAd loadAdWithSlotID: slotId
                                  request: request
                        completionHandler:^(PAGBannerAd *_Nullable ad, NSError *_Nullable error) {
                
                if ( error )
                {
                    MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
                    [self log: @"AdView failed to load with error: %@", adapterError];
                    
                    [delegate didFailToLoadAdViewAdWithError: adapterError];
                    
                    return;
                }
                
                if ( !ad )
                {
                    [self log: @"AdView ad (%@) NO FILL'd", slotId];
                    [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
                    
                    return;
                }
                
                [self log: @"AdView loaded: %@", slotId];
                
                self.adViewAd = ad;
                
                self.adViewAdDelegate = [[ALByteDanceAdViewAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
                self.adViewAd.delegate = self.adViewAdDelegate;
                
                [delegate didLoadAdForAdView: ad.bannerView];
            }];
        }
    });
}

#pragma mark - Native Ad Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    [self log: @"Loading %@native ad for slot id \"%@\"...", isBidding ? @"bidding " : @"", slotId];
    
    [self updateConsentWithParameters: parameters];
    
    [PAGConfig shareConfig].userDataString = [self createUserDataStringWithParameters: parameters isInitializing: NO];
    PAGNativeRequest *request = [PAGNativeRequest request];
    
    if ( isBidding )
    {
        [request setAdString: bidResponse];
    }
    
    dispatchOnMainQueue(^{
        
        [PAGLNativeAd loadAdWithSlotID: slotId request: request completionHandler:^(PAGLNativeAd *_Nullable ad, NSError *_Nullable error) {
            
            if ( error )
            {
                MAAdapterError *adapterError = [ALByteDanceMediationAdapter toMaxError: error];
                [self log: @"Native ad (%@) failed to load with error: %@", slotId, adapterError];
                
                [delegate didFailToLoadNativeAdWithError: adapterError];
                
                return;
            }
            
            if ( !ad )
            {
                [self log: @"Native ad (%@) NO FILL'd", slotId];
                [delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
                
                return;
            }
            
            [self log: @"Native ad loaded: %@. Preparing assets...", slotId];
            
            self.nativeAd = ad;
            
            self.nativeAdDelegate = [[ALByteDanceNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                    parameters: parameters
                                                                                     andNotify: delegate];
            self.nativeAd.delegate = self.nativeAdDelegate;
            
            PAGLMaterialMeta *nativeAdData = ad.data;
            
            NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
            BOOL isTemplateAd = [templateName al_isValidString];
            if ( isTemplateAd && ![nativeAdData.AdTitle al_isValidString] )
            {
                [self e: @"Native ad (%@) does not have required assets.", ad];
                [delegate didFailToLoadNativeAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
                
                return;
            }
            
            // Run image fetching tasks asynchronously in the background
            dispatch_group_t group = dispatch_group_create();
            
            __block MANativeAdImage *iconImage = nil;
            if ( nativeAdData.icon && [nativeAdData.icon.imageURL al_isValidURL] )
            {
                [self log: @"Fetching native ad icon: %@", nativeAdData.icon.imageURL];
                [self loadImageForURLString: nativeAdData.icon.imageURL group: group successHandler:^(UIImage *image) {
                    iconImage = [[MANativeAdImage alloc] initWithImage: image];
                }];
            }
            
            self.nativeAdRelatedView = [[PAGLNativeAdRelatedView alloc] init];
            [self.nativeAdRelatedView refreshWithNativeAd: ad];
            
            UIView *optionsView = self.nativeAdRelatedView.logoADImageView;
            UIView *mediaView = self.nativeAdRelatedView.mediaView;

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                // Timeout tasks if incomplete within the given time
                NSTimeInterval imageTaskTimeoutSeconds = [[parameters.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
                dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));
                
                // Create MANativeAd after images are loaded from remote URLs
                [self log: @"Creating native ad with assets"];
                
                // Currently we aren't rendering dislikeButton
                // If we need it, we need to add it to the subView manually. It is accessible through relatedView
                MANativeAd *maxNativeAd = [[MAPangleNativeAd alloc] initWithParentAdapter: self builderBlock:^(MANativeAdBuilder *builder) {
                    builder.title = nativeAdData.AdTitle;
                    builder.body = nativeAdData.AdDescription;
                    builder.callToAction = nativeAdData.buttonText;
                    builder.icon = iconImage;
                    builder.optionsView = optionsView;
                    builder.mediaView = mediaView;
                }];
                
                [self log: @"Native ad fully loaded: %@", slotId];
                [delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
            });
        }];
    });
}

#pragma mark - Helper Methods

- (NSString *)createUserDataStringWithParameters:(id<MAAdapterParameters>)parameters isInitializing:(BOOL)isInitializing
{
    if ( isInitializing )
    {
        return [NSString stringWithFormat: @"[{\"name\":\"mediation\",\"value\":\"MAX\"},{\"name\":\"adapter_version\",\"value\":\"%@\"}]", self.adapterVersion];
    }
    else
    {
        return [NSString stringWithFormat: @"[{\"name\":\"mediation\",\"value\":\"MAX\"},{\"name\":\"adapter_version\",\"value\":\"%@\"},{\"name\":\"hybrid_id\",\"value\":\"%@\"}]", self.adapterVersion, [parameters.serverParameters al_stringForKey: @"event_id"]];
    }
}

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    PAGConfig *configuration = [PAGConfig shareConfig];
    
    NSNumber *hasUserConsent = parameters.hasUserConsent;
    if ( hasUserConsent )
    {
        configuration.GDPRConsent = hasUserConsent.boolValue ? PAGGDPRConsentTypeConsent : PAGGDPRConsentTypeNoConsent;
    }
    
    NSNumber *isAgeRestrictedUser = parameters.isAgeRestrictedUser;
    if ( isAgeRestrictedUser )
    {
        configuration.childDirected = isAgeRestrictedUser.boolValue ? PAGChildDirectedTypeChild : PAGChildDirectedTypeNonChild;
    }
    
    NSNumber *isDoNotSell = parameters.isDoNotSell;
    if ( isDoNotSell )
    {
        configuration.doNotSell = isDoNotSell.boolValue ? PAGDoNotSellTypeNotSell : PAGDoNotSellTypeSell;
    }
}

- (void)loadImageForURLString:(NSString *)urlString group:(dispatch_group_t)group successHandler:(void (^)(UIImage *image))successHandler;
{
    // Pangle's image resource comes in the form of a URL which needs to be fetched in a non-blocking manner
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_group_enter(group);
        
        [[[NSURLSession sharedSession] dataTaskWithURL: [NSURL URLWithString: urlString]
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if ( error )
            {
                [self log: @"Failed to fetch native ad image with error: %@", error];
            }
            else if ( data )
            {
                [self log: @"Native ad image data retrieved"];
                
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

- (PAGBannerAdSize)bannerAdSizeForAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return kPAGBannerSize320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return kPAGBannerSize728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return kPAGBannerSize300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Ad view ad size invalid"];
        return kPAGBannerSize320x50;
    }
}

- (nullable UIImage *)appIconImage
{
    NSDictionary *icons = [[NSBundle mainBundle] infoDictionary][@"CFBundleIcons"];
    NSDictionary *primary = icons[@"CFBundlePrimaryIcon"];
    NSArray *files = primary[@"CFBundleIconFiles"];
    return [UIImage imageNamed: files.lastObject];
}

// Error code were sourced from https://www.pangleglobal.com/integration/error-code & old sdk class BUErrorCode
+ (MAAdapterError *)toMaxError:(NSError *)pangleError
{
    NSInteger pangleErrorCode = pangleError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( pangleErrorCode )
    {
        case -100: // sdk init config is unfinished
            adapterError = MAAdapterError.notInitialized;
            break;
        case -3: // parsed data has no ads
        case 20001: // no ads
            adapterError = MAAdapterError.noFill;
            break;
        case -2: // network request failed
        case 98764: // network error.
            adapterError = MAAdapterError.noConnection;
            break;
        case 10001: // parameter error
        case 40016: // The relationship between slot_id and app_id is invalid.
        case 40018: // Media package name is inconsistent with entry
        case 40019: // Media configuration ad type is inconsistent with request
        case 40006: // the ad slot ID is invalid
        case 40041: // SDK version is too low.
        case 40042: // New interstitial style use sdk version is too low. Plese upgrade SDK version to 3.5.5.0.
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case 10002: // timeout
            adapterError = MAAdapterError.timeout;
            break;
        case -6: // native template is invalid
        case -5: // native template addation is invalid
        case -4: // failed to open appstore
        case -1: // parsing failed
        case -702: // Playable error: has cache
        case -704: // Playable Error: unzip error
        case 101: // native Express ad, render result parse fail
        case 102: // native Express ad, template is invalid
        case 103: // native Express ad, template plugin is invalid
        case 104: // native Express ad, data is invalid
        case 105: // native Express ad, parse fail
        case 106: // native Express ad, render fail
        case 107: // native Express ad, render timeout
        case 109: // native Express ad, template load fail
        case 1000: // SDK stop forcefully
        case 20000: // Error code success
        case 40000: // http conent_type error
        case 40001: // http request pb error
        case 40002: // request app can't be empty
        case 40003: // request wap can't be empty
        case 40004: // missing ad slot description
        case 40005: // the ad slot size is invalid
        case 40007: // request the wrong number of ads
        case 40008: // wrong image size
        case 40009: // Media ID is illegal
        case 40010: // Media type is illegal
        case 40011: // Ad type is illegal
        case 40012: // Media access type is illegal and has been deprecated
        case 40013: // Code bit id is less than 900 million, but adType is not splash ad
        case 40014: // The redirect parameter is incorrect
        case 40015: // Media rectification exceeds deadline, request illegal
        case 40017: // Media access type is not legal API/SDK
        case 40020: // The ad space registered by developers exceeds daily request limit
        case 40021: // Apk signature sha1 value is inconsistent with media platform entry
        case 40022: // Whether the media request material is inconsistent with the media platform entry
        case 40023: // The OS field is incorrectly filled
        case 40024: // The SDK version is too low to return ads
        case 40025: // the SDK package is incomplete. It is recommended to verify the integrity of SDK package or contact technical support.
        case 40026: // Non-international account request for overseas delivery system
        case 40029: // The rendering method for slot ID does not match.
        case 50001: // ad server error
        case 401: // native Express ad, engine error
        case 402: // native Express ad, context error
        case 403: // native Express ad, item not exist
        case 112: // Dynamic 1 JS context empty
        case 113: // Dynamic 1 parse error
        case 117: // Dynamic 1 timeout
        case 118: // Dynamic 1 sub component does not exist
        case 123: // Dynamic 2 parse error
        case 127: // Dynamic 2 timeout
        case 128: // Dynamic 2 sub component does not exist
        case 40030: // Huawei browse impex cpid channeld code does not match.
        case 40031: // International request currency type is empty.
        case 40032: // OpenRTB request token is empty.
        case 40033: // Hard code not return ads, return message does not adjust.
        case 40043: // Preview flow invalid.
        case 98765: // Error undefined
        case 491: // slot ab, feature is disabled
        case 492: // slot ab, slot result is empty
        case 10003: // error code resource
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: pangleErrorCode
               thirdPartySdkErrorMessage: pangleError.localizedDescription];
#pragma clang diagnostic pop
}

@end

@implementation ALByteDanceInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGLInterstitialAd *)ad
{
    [self.parentAdapter log: @"Interstitial shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)adDidClick:(PAGLInterstitialAd *)ad
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)adDidDismiss:(PAGLInterstitialAd *)ad
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALByteDanceAppOpenAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAppOpenAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGLAppOpenAd *)ad
{
    [self.parentAdapter log: @"App Open ad shown"];
    [self.delegate didDisplayAppOpenAd];
}

- (void)adDidClick:(PAGLAppOpenAd *)ad
{
    [self.parentAdapter log: @"App Open ad clicked"];
    [self.delegate didClickAppOpenAd];
}

- (void)adDidDismiss:(PAGLAppOpenAd *)ad
{
    [self.parentAdapter log: @"App Open ad hidden"];
    [self.delegate didHideAppOpenAd];
}

@end

@implementation ALByteDanceRewardedVideoAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
}

- (void)adDidClick:(PAGRewardedAd *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userDidEarnReward:(PAGRewardModel *)rewardModel
{
    [self.parentAdapter log: @"Reward user with reward: %d %@", rewardModel.rewardAmount, rewardModel.rewardName];
    
    self.grantedReward = YES;
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userEarnRewardFailWithError:(NSError *)error
{
    [self.parentAdapter log: @"Reward failed with error: %@", error];
}

- (void)adDidDismiss:(PAGRewardedAd *)ad
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

@implementation ALByteDanceAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGBannerAd *)ad
{
    [self.parentAdapter log: @"AdView shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)adDidClick:(PAGBannerAd *)ad
{
    [self.parentAdapter log: @"AdView ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)adDidDismiss:(PAGBannerAd *)ad
{
    [self.parentAdapter log: @"AdView ad hidden"];
    [self.delegate didHideAdViewAd];
}

@end

@implementation ALByteDanceNativeAdViewAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters format:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.slotId = parameters.thirdPartyAdPlacementIdentifier;
        self.adFormat = adFormat;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad displayed: %@", self.adFormat.label, self.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)adDidClick:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad clicked: %@", self.adFormat.label, self.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)adDidDismiss:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native %@ ad hidden: %@", self.adFormat.label, self.slotId];
    [self.delegate didHideAdViewAd];
}

@end

@implementation ALByteDanceNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter parameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.slotId = parameters.thirdPartyAdPlacementIdentifier;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adDidShow:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native ad displayed: %@", self.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)adDidClick:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native ad clicked: %@", self.slotId];
    [self.delegate didClickNativeAd];
}

- (void)adDidDismiss:(PAGLNativeAd *)ad
{
    [self.parentAdapter log: @"Native ad hidden: %@", self.slotId];
}

@end

@implementation MAPangleNativeAd

- (instancetype)initWithParentAdapter:(ALByteDanceMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    PAGLNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views for interaction: native ad is nil."];
        return;
    }
    
    NSMutableArray *clickableViews = [NSMutableArray array];
    if ( [self.title al_isValidString] && maxNativeAdView.titleLabel )
    {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    if ( [self.body al_isValidString] && maxNativeAdView.bodyLabel )
    {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    if ( [self.callToAction al_isValidString] && maxNativeAdView.callToActionButton )
    {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    if ( self.icon && maxNativeAdView.iconImageView )
    {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    if ( self.mediaView && maxNativeAdView.mediaContentView )
    {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
    [nativeAd registerContainer: maxNativeAdView withClickableViews: clickableViews];
}

@end
