//
//  ALBidMachineMediationAdapter.m
//  Adapters
//
//  Created by Josh on 4/5/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALBidMachineMediationAdapter.h"
#import <BidMachine/BidMachine.h>

#define ADAPTER_VERSION @"1.9.4.1.0"

@interface ALBidMachineInterstitialDelegate : NSObject<BDMInterstitialDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidMachineRewardedDelegate : NSObject<BDMRewardedDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidMachineAdViewDelegate : NSObject<BDMBannerDelegate, BDMAdEventProducerDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidMachineNativeDelegate : NSObject<BDMNativeAdDelegate, BDMAdEventProducerDelegate>
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

@interface MABidMachineNativeAdRendering : NSObject<BDMNativeAdRendering>
@property (nonatomic, weak) MANativeAdView *adView;
- (instancetype)initWithNativeAdView:(MANativeAdView *)adView;
@end

@interface ALBidMachineMediationAdapter()
@property (nonatomic, strong) BDMInterstitial *interstitialAd;
@property (nonatomic, strong) BDMRewarded *rewardedAd;
@property (nonatomic, strong) BDMBannerView *adView;
@property (nonatomic, strong) BDMNativeAd *nativeAd;

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

        BDMSdkConfiguration *config = [[BDMSdkConfiguration alloc] init];
        config.testMode = [parameters isTesting];
        
        [self updateSettings: parameters];

        [BDMSdk.sharedSdk startSessionWithSellerID: sourceId configuration: config completion:^{
            [self log: @"BidMachine SDK successfully finished initialization with source id: %@", sourceId];

            ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALBidMachineSDKInitializationStatus, nil);
        }];
    }
    else
    {
        [self log: @"BidMachine SDK is already initialized"];
        completionHandler(ALBidMachineSDKInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return kBDMVersion;
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

    [self.nativeAd unregisterViews];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    [self updateSettings: parameters];

    NSString *signal = BDMSdk.sharedSdk.biddingToken;
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad..."];

    [self updateSettings: parameters];
    
    self.interstitialAd = [[BDMInterstitial alloc] init];
    self.interstitialAdapterDelegate = [[ALBidMachineInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;

    BDMInterstitialRequest *request = [[BDMInterstitialRequest alloc] init];
    request.bidPayload = parameters.bidResponse;
    [self.interstitialAd populateWithRequest: request];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];

    if ( ![self.interstitialAd canShow] )
    {
        [self log: @"Unable to show interstitial - ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithCode: -4205 errorString: @"Ad Display Failed"]];
        
        return;
    }
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    [self.interstitialAd presentFromRootViewController: presentingViewController];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad..."];

    [self updateSettings: parameters];
    
    self.rewardedAd = [[BDMRewarded alloc] init];
    self.rewardedAdapterDelegate = [[ALBidMachineRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;

    BDMRewardedRequest *request = [[BDMRewardedRequest alloc] init];
    request.bidPayload = parameters.bidResponse;
    [self.rewardedAd populateWithRequest: request];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];

    if ( ![self.rewardedAd canShow] )
    {
        [self log: @"Unable to show rewarded ad - ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
        
        return;
    }
    
    [self configureRewardForParameters: parameters];
    
    UIViewController *presentingViewController = [self presentingViewControllerFromParameters: parameters];
    [self.rewardedAd presentFromRootViewController: presentingViewController];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad...", adFormat.label];

    [self updateSettings: parameters];
    
    BDMBannerAdSize size = [self sizeFromAdFormat: adFormat];
    self.adView = [[BDMBannerView alloc] initWithFrame: (CGRect){.size = CGSizeFromBDMSize(size)}];
    self.adViewAdapterDelegate = [[ALBidMachineAdViewDelegate alloc] initWithParentAdapter: self
                                                                                    format: adFormat
                                                                                 andNotify: delegate];
    self.adView.delegate = self.adViewAdapterDelegate;
    self.adView.producerDelegate = self.adViewAdapterDelegate;
    self.adView.rootViewController = [ALUtils topViewControllerFromKeyWindow];

    BDMBannerRequest *request = [[BDMBannerRequest alloc] init];
    request.adSize = size;
    request.bidPayload = parameters.bidResponse;
    [self.adView populateWithRequest: request];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading native ad..."];
    
    [self updateSettings: parameters];

    self.nativeAd = [[BDMNativeAd alloc] init];
    self.nativeAdAdapterDelegate = [[ALBidMachineNativeDelegate alloc] initWithParentAdapter: self
                                                                                  parameters: parameters
                                                                                   andNotify: delegate];
    self.nativeAd.delegate = self.nativeAdAdapterDelegate;
    self.nativeAd.producerDelegate = self.nativeAdAdapterDelegate;

    BDMNativeAdRequest *request = [[BDMNativeAdRequest alloc] init];
    request.bidPayload = parameters.bidResponse;
    [self.nativeAd makeRequest: request];
}

#pragma mark - Shared Methods

+ (MAAdapterError *)toMaxError:(NSError *)bidmachineError
{
    NSInteger bidmachineErrorCode = bidmachineError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;

    switch ( bidmachineErrorCode )
    {
        case BDMErrorCodeNoConnection:
            adapterError = MAAdapterError.noConnection;
            break;
        case BDMErrorCodeTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case BDMErrorCodeBadContent:
        case BDMErrorCodeNoContent:
            adapterError = MAAdapterError.noFill;
            break;
        case BDMErrorCodeUsedAlready:
        case BDMErrorCodeException:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case BDMErrorCodeWasExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case BDMErrorCodeInternal:
            adapterError = MAAdapterError.internalError;
            break;
        case BDMErrorCodeHTTPServerError:
            adapterError = MAAdapterError.serverError;
            break;
        case BDMErrorCodeHTTPBadRequest:
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

- (BDMBannerAdSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return BDMBannerAdSize320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return BDMBannerAdSize728x90;
    }
    else if ( adFormat == MAAdFormat.mrec )
    {
        return BDMBannerAdSize300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return BDMBannerAdSize320x50;
    }
}

- (void)updateSettings:(id<MAAdapterParameters>)parameters
{
    NSNumber *isAgeRestrictedUser = [parameters isAgeRestrictedUser];
    if ( isAgeRestrictedUser  )
    {
        BDMSdk.sharedSdk.restrictions.coppa = isAgeRestrictedUser.boolValue;
    }

    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        BDMSdk.sharedSdk.restrictions.subjectToGDPR = YES;
        
        NSNumber *hasUserConsent = [parameters hasUserConsent];
        if ( hasUserConsent )
        {
            BDMSdk.sharedSdk.restrictions.hasConsent = hasUserConsent.boolValue;
        }
    }
    else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
    {
        BDMSdk.sharedSdk.restrictions.subjectToGDPR = NO;
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

- (void)interstitialReadyToPresent:(BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitial:(BDMInterstitial *)interstitial failedWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialWillPresent:(BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitial:(BDMInterstitial *)interstitial failedToPresentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
}

- (void)interstitialDidDismiss:(BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialRecieveUserInteraction:(BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
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

- (void)rewardedReadyToPresent:(BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewarded:(BDMRewarded *)rewarded failedWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedWillPresent:(BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
}

- (void)rewarded:(BDMRewarded *)rewarded failedToPresentWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewardedDidDismiss:(BDMRewarded *)rewarded
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

- (void)rewardedRecieveUserInteraction:(BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedFinishRewardAction:(BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad should grant reward"];
    self.grantedReward = YES;
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

- (void)bannerViewReadyToPresent:(BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView loaded"];
    [self.delegate didLoadAdForAdView: bannerView];
}

- (void)bannerView:(BDMBannerView *)bannerView failedWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"AdView failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)didProduceImpression:(id<BDMAdEventProducer>)producer
{
    [self.parentAdapter log: @"AdView shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewWillPresentScreen:(BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView start handling click"];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewRecieveUserInteraction:(BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewDidDismissScreen:(BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"AdView finished handling click"];
    [self.delegate didCollapseAdViewAd];
}

- (void)didProduceUserAction:(id<BDMAdEventProducer>)producer
{
    [self.parentAdapter log: @"AdView produced user interaction"];
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

- (void)nativeAd:(BDMNativeAd *)nativeAd readyToPresentAd:(BDMAuctionInfo *)auctionInfo
{
    [self.parentAdapter log: @"Native ad loaded"];

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
    if ( nativeAd.iconUrl && [nativeAd.iconUrl al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad icon: %@", nativeAd.iconUrl];
        [self.parentAdapter loadImageForURLString: nativeAd.iconUrl group: group successHandler:^(UIImage *image) {
            iconImage = [[MANativeAdImage alloc] initWithImage: image];
        }];
    }
    
    __block UIImageView *mainImageView = nil;
    if ( nativeAd.mainImageUrl && [nativeAd.mainImageUrl al_isValidURL] )
    {
        [self.parentAdapter log: @"Fetching native ad main image: %@", nativeAd.mainImageUrl];
        [self.parentAdapter loadImageForURLString: nativeAd.mainImageUrl group: group successHandler:^(UIImage *image) {
            mainImageView = [[UIImageView alloc] initWithImage: image];
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
            builder.callToAction = nativeAd.CTAText;
            builder.icon = iconImage;
            builder.mediaView = mainImageView;
        }];
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

- (void)nativeAd:(BDMNativeAd *)nativeAd failedWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)didProduceImpression:(id<BDMAdEventProducer>)producer
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)didProduceUserAction:(id<BDMAdEventProducer>)producer
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
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
    BDMNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
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

    NSError *error = nil;
    MABidMachineNativeAdRendering *adRendering = [[MABidMachineNativeAdRendering alloc] initWithNativeAdView: maxNativeAdView];
    [self.parentAdapter.nativeAd presentOn: maxNativeAdView
                            clickableViews: clickableViews
                               adRendering: adRendering
                                controller: [ALUtils topViewControllerFromKeyWindow]
                                     error: &error];
    if ( error )
    {
        [self.parentAdapter log: @"Native ad failed to present with error: %@", error];
    }
}

@end
