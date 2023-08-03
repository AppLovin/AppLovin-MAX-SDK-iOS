//
//  ALBidMachineMediationAdapter.m
//  Adapters
//
//  Created by Josh on 4/5/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALBidMachineMediationAdapter.h"
#import <BidMachine/BidMachine.h>
#import <BidMachineApiCore/BidMachineApiCore.h>

#define ADAPTER_VERSION @"2.3.0.0.0"

@interface ALBidMachineInterstitialDelegate : NSObject <BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidMachineRewardedDelegate : NSObject <BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidMachineAdViewDelegate : NSObject <BidMachineAdDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidMachineNativeDelegate : NSObject <BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MABidMachineNativeAd : MANativeAd
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface MABidMachineNativeAdRendering : NSObject <BidMachineNativeAdRendering>
@property (nonatomic, weak) MANativeAdView *adView;
- (instancetype)initWithNativeAdView:(MANativeAdView *)adView;
@end

@interface ALBidMachineMediationAdapter ()
@property (nonatomic, strong) BidMachineInterstitial *interstitialAd;
@property (nonatomic, strong) BidMachineRewarded *rewardedAd;
@property (nonatomic, strong) BidMachineBanner *adView;
@property (nonatomic, strong) BidMachineNative *nativeAd;

@property (nonatomic, strong) ALBidMachineInterstitialDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALBidMachineRewardedDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALBidMachineAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALBidMachineNativeDelegate *nativeAdAdapterDelegate;
@end

@implementation ALBidMachineMediationAdapter
static NSTimeInterval const kDefaultImageTaskTimeoutSeconds = 10.0;
static ALAtomicBoolean *ALBidMachineSDKInitialized;
static MAAdapterInitializationStatus ALBidMachineSDKInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALBidMachineSDKInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    if ( [ALBidMachineSDKInitialized compareAndSet: NO update: YES] )
    {
        ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *sourceId = [parameters.serverParameters al_stringForKey: @"source_id"];
        [self log: @"Initializing BidMachine SDK with source id: %@", sourceId];
        
        [BidMachineSdk.shared populate:^(id<BidMachineInfoBuilderProtocol> builder) {
            
            if ( [parameters isTesting] )
            {
                [builder withTestMode: YES];
                [builder withLoggingMode: YES];
                [builder withEventLoggingMode: YES];
                [builder withBidLoggingMode: YES];
            }
        }];
        
        [self updateSettings: parameters];
        
        [BidMachineSdk.shared initializeSdk: sourceId];
    }
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return BidMachineSdk.sdkVersion;
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
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate.delegate = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate.delegate = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate.delegate = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal for %@ ad...", parameters.adFormat.label];
    
    [self updateSettings: parameters];
    
    BidMachinePlacementFormat bidMachinePlacementFormat = [self bidMachinePlacementFormatFromAdFormat: parameters.adFormat];
    [BidMachineSdk.shared tokenWith: bidMachinePlacementFormat completion:^(NSString *_Nullable signal) {
        [self log: @"Signal collection successful with%@ valid signal", [signal al_isValidString] ? @"" : @"out"];
        [delegate didCollectSignal: signal];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad..."];
    
    [self updateSettings: parameters];
    
    NSError *configurationError = nil;
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration: BidMachinePlacementFormatInterstitial error: &configurationError];
    
    if ( configurationError )
    {
        [self log: @"Interstitial ad failed to load with error: %@", configurationError];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToLoadInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.invalidConfiguration
                                                                       thirdPartySdkErrorCode: configurationError.code
                                                                    thirdPartySdkErrorMessage: configurationError.localizedDescription]];
#pragma clang diagnostic pop
        
        return;
    }
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload: parameters.bidResponse];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [BidMachineSdk.shared interstitial: config :^(BidMachineInterstitial *interstitialAd, NSError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Interstitial ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !interstitialAd )
        {
            [weakSelf log: @"Interstitial ad not ready"];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        weakSelf.interstitialAd = interstitialAd;
        weakSelf.interstitialAdapterDelegate = [[ALBidMachineInterstitialDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.interstitialAd.delegate = weakSelf.interstitialAdapterDelegate;
        
        [weakSelf.interstitialAd loadAd];
    }];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( ![self.interstitialAd canShow] )
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                  thirdPartySdkErrorCode: 0
                                                               thirdPartySdkErrorMessage: @"Interstitial ad not ready"]];
#pragma clang diagnostic pop
        
        return;
    }
    
    self.interstitialAd.controller = [self presentingViewControllerFromParameters: parameters];
    [self.interstitialAd presentAd];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad..."];
    
    [self updateSettings: parameters];
    
    NSError *configurationError = nil;
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration: BidMachinePlacementFormatRewarded error: &configurationError];
    
    if ( configurationError )
    {
        [self log: @"Rewarded ad failed to load with error: %@", configurationError];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToLoadRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.invalidConfiguration
                                                                   thirdPartySdkErrorCode: configurationError.code
                                                                thirdPartySdkErrorMessage: configurationError.localizedDescription]];
#pragma clang diagnostic pop
        
        return;
    }
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload: parameters.bidResponse];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [BidMachineSdk.shared rewarded: config :^(BidMachineRewarded *rewardedAd, NSError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Rewarded ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            
            return;
        }
        
        if ( !rewardedAd )
        {
            [weakSelf log: @"Rewarded ad failed to load: ad is nil"];
            [delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        weakSelf.rewardedAd = rewardedAd;
        weakSelf.rewardedAdapterDelegate = [[ALBidMachineRewardedDelegate alloc] initWithParentAdapter: weakSelf andNotify: delegate];
        weakSelf.rewardedAd.delegate = weakSelf.rewardedAdapterDelegate;
        
        [weakSelf.rewardedAd loadAd];
    }];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( ![self.rewardedAd canShow] )
    {
        [self log: @"Unable to show rewarded ad - ad not ready"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                              thirdPartySdkErrorCode: 0
                                                           thirdPartySdkErrorMessage: @"Rewarded ad not ready"]];
#pragma clang diagnostic pop
        
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    self.rewardedAd.controller = [self presentingViewControllerFromParameters: parameters];
    [self.rewardedAd presentAd];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad...", adFormat.label];
    
    [self updateSettings: parameters];
    
    BidMachinePlacementFormat format = [self bidMachinePlacementFormatFromAdFormat: adFormat];
    
    NSError *configurationError = nil;
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration: format error: &configurationError];
    
    if ( configurationError )
    {
        [self log: @"AdView ad failed to load with error: %@", configurationError];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToLoadAdViewAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.invalidConfiguration
                                                                 thirdPartySdkErrorCode: configurationError.code
                                                              thirdPartySdkErrorMessage: configurationError.localizedDescription]];
#pragma clang diagnostic pop
        
        return;
    }
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload: parameters.bidResponse];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [BidMachineSdk.shared banner: config :^(BidMachineBanner *bannerAd, NSError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"AdView failed to load with error: %@", adapterError];
            [delegate didFailToLoadAdViewAdWithError: adapterError];
            
            return;
        }
        
        if ( !bannerAd )
        {
            [weakSelf log: @"AdView ad failed to load: ad is nil"];
            [delegate didFailToLoadAdViewAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        weakSelf.adView = bannerAd;
        weakSelf.adViewAdapterDelegate = [[ALBidMachineAdViewDelegate alloc] initWithParentAdapter: weakSelf
                                                                                            format: adFormat
                                                                                         andNotify: delegate];
        weakSelf.adView.delegate = weakSelf.adViewAdapterDelegate;
        weakSelf.adView.controller = [ALUtils topViewControllerFromKeyWindow];
        [weakSelf.adView loadAd];
    }];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad..."];
    
    [self updateSettings: parameters];
    
    NSError *configurationError = nil;
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration: BidMachinePlacementFormatNative error: &configurationError];
    
    if ( configurationError )
    {
        [self log: @"Native ad failed to load with error: %@", configurationError];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.invalidConfiguration
                                                                 thirdPartySdkErrorCode: configurationError.code
                                                              thirdPartySdkErrorMessage: configurationError.localizedDescription]];
#pragma clang diagnostic pop
        
        return;
    }
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload: parameters.bidResponse];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    [BidMachineSdk.shared native: config :^(BidMachineNative *nativeAd, NSError *error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Native ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadNativeAdWithError: adapterError];
            
            return;
        }
        
        if ( !nativeAd )
        {
            [weakSelf log: @"Native ad failed to load: ad is nil"];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.adNotReady];
            
            return;
        }
        
        weakSelf.nativeAd = nativeAd;
        weakSelf.nativeAdAdapterDelegate = [[ALBidMachineNativeDelegate alloc] initWithParentAdapter: weakSelf
                                                                                          parameters: parameters
                                                                                           andNotify: delegate];
        weakSelf.nativeAd.delegate = weakSelf.nativeAdAdapterDelegate;
        weakSelf.nativeAd.controller = [ALUtils topViewControllerFromKeyWindow];
        [weakSelf.nativeAd loadAd];
    }];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)bidmachineError
{
    NSInteger bidmachineErrorCode = bidmachineError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( bidmachineErrorCode )
    {
        case 100: // No connection
            adapterError = MAAdapterError.noConnection;
            break;
        case 102: // Timeout
            adapterError = MAAdapterError.timeout;
            break;
        case 103: // No Content
            adapterError = MAAdapterError.noFill;
            break;
        case 104: // Exception
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case 107: // Ad Expired
            adapterError = MAAdapterError.adExpiredError;
            break;
        case 101: // Bad Content
        case 106: // Ad Destroyed
        case 108: // Interior Error
            adapterError = MAAdapterError.internalError;
            break;
        case 109: // Server Error
        case 200: // Header Bidding Error
            adapterError = MAAdapterError.serverError;
            break;
        case 110: // Bad Request
            adapterError = MAAdapterError.badRequest;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                  thirdPartySdkErrorCode: bidmachineErrorCode
               thirdPartySdkErrorMessage: bidmachineError.localizedDescription];
#pragma clang diagnostic pop
}

- (BidMachinePlacementFormat)bidMachinePlacementFormatFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return BidMachinePlacementFormatBanner320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return BidMachinePlacementFormatBanner728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return BidMachinePlacementFormatBanner300x250;
    }
    else if ( adFormat == MAAdFormat.native )
    {
        return BidMachinePlacementFormatNative;
    }
    else if ( adFormat == MAAdFormat.interstitial )
    {
        return BidMachinePlacementFormatInterstitial;
    }
    else if ( adFormat == MAAdFormat.rewarded || adFormat == MAAdFormat.rewardedInterstitial )
    {
        return BidMachinePlacementFormatRewarded;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return BidMachinePlacementFormatUnknown;
    }
}

- (void)updateSettings:(id<MAAdapterParameters>)parameters
{
    __block id<BidMachineRegulationInfoBuilderProtocol> regulationBuilder = nil;
    [BidMachineSdk.shared.regulationInfo populate:^(id<BidMachineRegulationInfoBuilderProtocol> builder) {
        regulationBuilder = builder;
    }];
    
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser )
    {
        [regulationBuilder withCOPPA: isAgeRestrictedUser.boolValue];
    }
    
    if ( ALSdk.versionCode >= 11040299 )
    {
        if ( parameters.consentString )
        {
            [regulationBuilder withGDPRConsentString: parameters.consentString];
        }
    }
    
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent )
    {
        [regulationBuilder withGDPRConsent: hasUserConsent.boolValue];
    }
    
    NSNumber *isDoNotSell = [parameters isDoNotSell];
    if ( isDoNotSell )
    {
        [regulationBuilder withUSPrivacyString: isDoNotSell.boolValue ? @"1YY-" : @"1YN-"];
    }
    else
    {
        [regulationBuilder withUSPrivacyString: @"1---"];
    }
}

- (void)loadImageForURLString:(NSString *)urlString group:(dispatch_group_t)group successHandler:(void (^)(UIImage *image))successHandler;
{
    // BidMachine's image resource comes in the form of a URL which needs to be fetched in a non-blocking manner
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

- (UIViewController *)presentingViewControllerFromParameters:(id<MAAdapterResponseParameters>)parameters
{
    return parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

@end

@implementation MABidMachineNativeAdRendering

- (instancetype)initWithNativeAdView:(MANativeAdView *)adView
{
    self = [super init];
    if ( self )
    {
        self.adView = adView;
    }
    return self;
}

- (UILabel *)callToActionLabel
{
    return self.adView.callToActionButton.titleLabel;
}

- (UILabel *)descriptionLabel
{
    return self.adView.bodyLabel;
}

- (UILabel *)titleLabel
{
    return self.adView.titleLabel;
}

- (UIImageView *)iconView
{
    return self.adView.iconImageView;
}

- (UIView *)mediaContainerView
{
    return self.adView.mediaContentView;
}

- (UIView *)adChoiceView
{
    return nil;
}

@end

@implementation ALBidMachineInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    
    NSString *creativeId = ad.auctionInfo.creativeId;
    NSDictionary *extraInfo;
    
    if ( [creativeId al_isValidString] )
    {
        extraInfo = @{@"creative_id" : creativeId};
    }
    
    [self.delegate didLoadInterstitialAdWithExtraInfo: extraInfo];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)didPresentAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad shown"];
}

- (void)didTrackImpression:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad impression tracked"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)didDismissAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)willPresentScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad screen will present"];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad interaction tracked"];
}

- (void)didDismissScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad screen dismissed"];
}

- (void)didExpired:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Interstitial ad expired"];
}

@end

@implementation ALBidMachineRewardedDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)didLoadAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    
    NSString *creativeId = ad.auctionInfo.creativeId;
    NSDictionary *extraInfo;
    
    if ( [creativeId al_isValidString] )
    {
        extraInfo = @{@"creative_id" : creativeId};
    }
    
    [self.delegate didLoadRewardedAdWithExtraInfo: extraInfo];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)didPresentAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad shown"];
}

- (void)didTrackImpression:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad impression tracked"];
    [self.delegate didDisplayRewardedAd];
}

- (void)didDismissAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad hidden"];
    
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.delegate didHideRewardedAd];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)didReceiveReward:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad should grant reward"];
    self.grantedReward = YES;
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)willPresentScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad screen will present"];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad interaction tracked"];
}

- (void)didDismissScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad screen dismissed"];
}

- (void)didExpired:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad expired"];
}

@end

@implementation ALBidMachineAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.format = format;
    }
    return self;
}

- (void)didLoadAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView loaded"];
    
    NSString *creativeId = ad.auctionInfo.creativeId;
    NSDictionary *extraInfo;
    
    if ( [creativeId al_isValidString] )
    {
        extraInfo = @{@"creative_id" : creativeId};
    }
    
    [self.delegate didLoadAdForAdView: self.parentAdapter.adView withExtraInfo: extraInfo];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

-(void)didTrackImpression:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)didPresentAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView ad presented"];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)willPresentScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView screen will present"];
    [self.delegate didExpandAdViewAd];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView click tracked"];
}

- (void)didDismissScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView dismissed screen"];
    [self.delegate didCollapseAdViewAd];
}

- (void)didDismissAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView ad hidden"];
    [self.delegate didHideAdViewAd];
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayAdViewAdWithError: adapterError];
}

- (void)didExpired:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"AdView expired"];
}

@end

@implementation ALBidMachineNativeDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.parameters = parameters;
    }
    return self;
}

- (void)didLoadAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad loaded"];
    
    BidMachineNative *nativeAd = self.parentAdapter.nativeAd;
    
    if ( !nativeAd )
    {
        [self.parentAdapter log: @"Native ad cant't be nil"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        
        return;
    }
    
    if ( ![nativeAd canShow] )
    {
        [self.parentAdapter log: @"Native ad not ready to show"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
    NSString *templateName = [self.parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.title al_isValidString] )
    {
        [self.parentAdapter log: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    // Run image fetching tasks asynchronously in the background
    dispatch_group_t group = dispatch_group_create();
    
    __block MANativeAdImage *iconImage = nil;
    if ( nativeAd.icon && [nativeAd.icon al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad icon: %@", nativeAd.icon];
        [self.parentAdapter loadImageForURLString: nativeAd.icon group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    __block UIImageView *mainImageView = nil;
    __block MANativeAdImage *mainImage = nil;
    if ( nativeAd.main && [nativeAd.main al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad main image: %@", nativeAd.main];
        [self.parentAdapter loadImageForURLString: nativeAd.main group: group successHandler:^(UIImage *image) {
            mainImageView = [[UIImageView alloc] initWithImage: image];
            mainImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Timeout tasks if incomplete within the given time
        NSTimeInterval imageTaskTimeoutSeconds = [[self.parameters.serverParameters al_numberForKey: @"image_task_timeout_seconds" defaultValue: @(kDefaultImageTaskTimeoutSeconds)] doubleValue];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t) (imageTaskTimeoutSeconds * NSEC_PER_SEC)));
        
        MANativeAd *maxNativeAd = [[MABidMachineNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                                           parameters: self.parameters
                                                                         builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.body = nativeAd.body;
            builder.callToAction = nativeAd.cta;
            builder.icon = iconImage;
            if ( ALSdk.versionCode >= 11040299 )
            {
                [builder performSelector: @selector(setMainImage:) withObject: mainImage];
            }
            builder.mediaView = mainImageView;
        }];
        
        NSString *creativeId = nativeAd.auctionInfo.creativeId;
        NSDictionary *extraInfo;
        
        if ( [creativeId al_isValidString] )
        {
            extraInfo = @{@"creative_id" : creativeId};
        }
        
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
    });
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)didTrackImpression:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)didPresentAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad presented"];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad user interaction tracked"];
}

- (void)willPresentScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad screen will present"];
}

- (void)didDismissScreen:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad screen dismissed"];
}

- (void)didDismissAd:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad hidden"];
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol>)ad :(NSError *)error
{
    [self.parentAdapter log: @"Native ad failed to present with error: %@", error];
}

- (void)didExpired:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Native ad expired"];
}

@end

@implementation MABidMachineNativeAd

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.parameters = parameters;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
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
    
    [self prepareForInteractionClickableViews: clickableViews withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(MANativeAdView *)container
{
    BidMachineNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    NSError *error = nil;
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    MABidMachineNativeAdRendering *adRendering = [[MABidMachineNativeAdRendering alloc] initWithNativeAdView: container];
    self.parentAdapter.nativeAd.controller = [ALUtils topViewControllerFromKeyWindow];
    [self.parentAdapter.nativeAd presentAd: container : adRendering error: &error];
    
    if ( error )
    {
        [self.parentAdapter e: @"Native ad failed to present with error: %@", error];
        return NO;
    }
    
    return YES;
}

@end
