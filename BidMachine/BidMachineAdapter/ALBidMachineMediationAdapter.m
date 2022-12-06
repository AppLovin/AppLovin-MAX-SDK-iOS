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

#define ADAPTER_VERSION @"1.9.5.0.2"

@interface ALBidMachineInterstitialDelegate : NSObject<BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidMachineRewardedDelegate : NSObject<BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidMachineAdViewDelegate : NSObject<BidMachineAdDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidMachineNativeDelegate : NSObject<BidMachineAdDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MABidMachineNativeAd : MANativeAd
@property (nonatomic, weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdapterResponseParameters> parameters;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
@end

@interface MABidMachineNativeAdRendering : NSObject<BidMachineNativeAdRendering>
@property (nonatomic, weak) MANativeAdView *adView;
- (instancetype)initWithNativeAdView:(MANativeAdView *)adView;
@end

@interface ALBidMachineMediationAdapter()
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

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( [ALBidMachineSDKInitialized compareAndSet: NO update: YES] )
    {
        ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSString *sourceId = [parameters.serverParameters al_stringForKey: @"source_id"];
        [self log: @"Initializing BidMachine SDK with source id: %@", sourceId];
        
        [BidMachineSdk.shared populate:^(id<BidMachineInfoBuilderProtocol> builder) {
            [builder withTestMode:[parameters isTesting]];
//            Test loging
//            [builder withLoggingMode:YES];
//            [builder withEventLoggingMode:YES];
//            [builder withBidLoggingMode:YES];
        }];
        
        [self updateSettings: parameters];
        [BidMachineSdk.shared initializeSdk: sourceId];
        
        [self log: @"BidMachine SDK successfully finished initialization with source id: %@", sourceId];
        ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
        completionHandler(ALBidMachineSDKInitializationStatus, nil);
    }
    else
    {
        [self log: @"BidMachine SDK is already initialized"];
        completionHandler(ALBidMachineSDKInitializationStatus, nil);
    }
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
    self.interstitialAdapterDelegate = nil;
    
    self.rewardedAd.delegate = nil;
    self.rewardedAd = nil;
    self.rewardedAdapterDelegate = nil;
    
    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
    
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateSettings: parameters];
    
    NSString *signal = BidMachineSdk.shared.token;
    
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad..."];
    
    [self updateSettings: parameters];
    
    __weak typeof(self) weakSelf = self;
    
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration:BidMachinePlacementFormatInterstitial error:nil];
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload:parameters.bidResponse];
    }];
    
    [BidMachineSdk.shared interstitial:config :^(BidMachineInterstitial *interstitial, NSError *error) {
        if (error) {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Interstitial failed to load ad with error: %@", adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            return;
        }
        [weakSelf loadInterstitialAd: interstitial andNotify: delegate];
    }];
}

- (void)loadInterstitialAd:(BidMachineInterstitial *)interstitialAd andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    if ( !interstitialAd )
    {
        [self log: @"Interstitial ad cant't be nil"];
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
        return;
    }
    
    self.interstitialAd = interstitialAd;
    self.interstitialAdapterDelegate = [[ALBidMachineInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    [self.interstitialAd loadAd];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( ![self.interstitialAd canShow] )
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205
                                                                             errorString: @"Ad Display Failed"
                                                                mediatedNetworkErrorCode: 0
                                                             mediatedNetworkErrorMessage: @"Interstitial ad not ready"]];
        
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
    
    __weak typeof(self) weakSelf = self;
    
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration:BidMachinePlacementFormatRewarded error:nil];
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload:parameters.bidResponse];
    }];
    
    [BidMachineSdk.shared rewarded:config :^(BidMachineRewarded *rewarded, NSError *error) {
        if (error) {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"Rewarded failed to load ad with error: %@", adapterError];
            [delegate didFailToLoadRewardedAdWithError: adapterError];
            return;
        }
        [weakSelf loadRewardedAd: rewarded andNotify: delegate];
    }];
}

- (void)loadRewardedAd:(BidMachineRewarded *)rewardedAd andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    if ( !rewardedAd )
    {
        [self log: @"Rewarded ad cant't be nil"];
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
        return;
    }
    
    self.rewardedAd = rewardedAd;
    self.rewardedAdapterDelegate = [[ALBidMachineRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;

    [self.rewardedAd loadAd];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];

    if ( ![self.rewardedAd canShow] )
    {
        [self log: @"Unable to show rewarded ad - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithCode: -4205
                                                                         errorString: @"Ad Display Failed"
                                                            mediatedNetworkErrorCode: 0
                                                         mediatedNetworkErrorMessage: @"Rewarded ad not ready"]];

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
    
    __weak typeof(self) weakSelf = self;
    
    BidMachinePlacementFormat format = [self formatFromAdFormat:adFormat];
    
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration:format error:nil];
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload:parameters.bidResponse];
    }];
    
    [BidMachineSdk.shared banner:config :^(BidMachineBanner *banner, NSError *error) {
        if (error) {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"AdView failed to load with error: %@", adapterError];
            [delegate didFailToLoadAdViewAdWithError: adapterError];
            return;
        }
        [weakSelf loadBannerAd: banner
                      adFormat: adFormat
                     andNotify: delegate];
    }];
}

- (void)loadBannerAd:(BidMachineBanner *)bannerAd adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    if ( !bannerAd )
    {
        [self log: @"AdView ad cant't be nil"];
        [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
        return;
    }
    
    self.adView = bannerAd;
    self.adViewAdapterDelegate = [[ALBidMachineAdViewDelegate alloc] initWithParentAdapter: self
                                                                                    format: adFormat
                                                                                 andNotify: delegate];
    self.adView.delegate = self.adViewAdapterDelegate;
    self.adView.controller = [ALUtils topViewControllerFromKeyWindow];
    
    [self.adView loadAd];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad..."];

    [self updateSettings: parameters];
    
    __weak typeof(self) weakSelf = self;
    
    id<BidMachineRequestConfigurationProtocol> config = [BidMachineSdk.shared requestConfiguration:BidMachinePlacementFormatNative error:nil];
    
    [config populate:^(id<BidMachineRequestBuilderProtocol> builder) {
        [builder withPayload:parameters.bidResponse];
    }];
    
    [BidMachineSdk.shared native:config :^(BidMachineNative *native, NSError *error) {
        if (error) {
            MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
            [weakSelf log: @"AdView failed to load with error: %@", adapterError];
            [delegate didFailToLoadNativeAdWithError: adapterError];
            return;
        }
        [weakSelf loadNativeAd:native
                 forParameters:parameters
                     andNotify:delegate];
    }];
}

- (void)loadNativeAd:(BidMachineNative *)nativeAd forParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    if ( !nativeAd )
    {
        [self log: @"Native ad cant't be nil"];
        [delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        return;
    }
    
    self.nativeAd = nativeAd;
    self.nativeAdAdapterDelegate = [[ALBidMachineNativeDelegate alloc] initWithParentAdapter: self
                                                                                  parameters: parameters
                                                                                   andNotify: delegate];
    self.nativeAd.delegate = self.nativeAdAdapterDelegate;
    self.nativeAd.controller = [ALUtils topViewControllerFromKeyWindow];
    [self.nativeAd loadAd];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)bidmachineError
{
    NSInteger bidmachineErrorCode = bidmachineError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
//    case .connection: return 100
//    case .badContent: return 101
//    case .timeout: return 102
//    case .noContent: return 103
//    case .exception: return 104
//    case .wasDestroyed: return 106
//    case .wasExpired: return 107
//    case .interior: return 108
//    case .server: return 109
//    case .badRequest: return 110
//    case .headerBidding: return 200

    switch ( bidmachineErrorCode )
    {
        case 100:
            adapterError = MAAdapterError.noConnection;
            break;
        case 102:
            adapterError = MAAdapterError.timeout;
            break;
        case 101:
        case 103:
            adapterError = MAAdapterError.noFill;
            break;
        case 104:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case 107:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case 108:
        case 106:
            adapterError = MAAdapterError.internalError;
            break;
        case 109:
        case 200:
            adapterError = MAAdapterError.serverError;
            break;
        case 110:
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

- (BidMachinePlacementFormat)formatFromAdFormat:(MAAdFormat *)adFormat
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
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return BidMachinePlacementFormatBanner;
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

    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        [regulationBuilder withGDPRZone: YES];

        NSNumber *hasUserConsent = [parameters hasUserConsent];
        if ( hasUserConsent )
        {
            [regulationBuilder withGDPRConsent: hasUserConsent.boolValue];
        }
    }
    else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
    {
        [regulationBuilder withGDPRZone: NO];
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

- (UIView *)adChoiceView {
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

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad
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

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad
{
    // Every time
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

// NO-OP

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Expire ad before showing
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Present SKStore screen
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Dismiss SKStore screen
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
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

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad
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

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad
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

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad
{
    // Every time
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)didReceiveReward:(id<BidMachineAdProtocol>)ad
{
    [self.parentAdapter log: @"Rewarded ad should grant reward"];
    self.grantedReward = YES;
}

// NO-OP

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Expire ad before showing
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Present SKStore screen
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Dismiss SKStore screen
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
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

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad
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

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad
{
    [self.parentAdapter log: @"AdView start handling click"];
    [self.delegate didExpandAdViewAd];
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad
{
    [self.parentAdapter log: @"AdView finished handling click"];
    [self.delegate didCollapseAdViewAd];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad
{
    // Every time
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad
{
    // One time for ad
    [self.parentAdapter log: @"AdView shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad
{
    // One time for ad
    [self.parentAdapter log: @"AdView produced user interaction"];
}

// NO-OP

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    
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

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad
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
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imageTaskTimeoutSeconds * NSEC_PER_SEC)));

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

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    // One time for ad
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    // Every time
}

//NO-OP

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    
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

    // Note: Clickable views not required for present ad
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
    [self.parentAdapter.nativeAd presentAd:container :adRendering error:&error];

    if ( error )
    {
        [self.parentAdapter e: @"Native ad failed to present with error: %@", error];
        return NO;
    }

    return YES;
}

@end
