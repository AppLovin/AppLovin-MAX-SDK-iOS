//
//  ALBidMachineMediationAdapter.m
//

#import "ALBidMachineMediationAdapter.h"
#import <BidMachine/BidMachine.h>

#define ADAPTER_VERSION @"1.9.2.0"

@interface ALBidMachineMediationAdapterInterstitialAdDelegate : NSObject<BDMInterstitialDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALBidMachineMediationAdapterRewardedAdDelegate : NSObject<BDMRewardedDelegate>
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALBidMachineMediationAdapterAdViewDelegate : NSObject<BDMBannerDelegate, BDMAdEventProducerDelegate>
@property (nonatomic,   weak) MAAdFormat *format;
@property (nonatomic,   weak) ALBidMachineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALBidMachineMediationAdapterNativeAdDelegate : NSObject<BDMNativeAdDelegate, BDMAdEventProducerDelegate>
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

@interface MABidMachineNativeAdRendering : NSObject <BDMNativeAdRendering>
@property (nonatomic, weak) MANativeAdView *adView;
- (instancetype)initWithNativeAdView:(MANativeAdView *)adView;
@end

@interface ALBidMachineMediationAdapter ()

@property (nonatomic, strong) BDMInterstitial *interstitialAd;
@property (nonatomic, strong) BDMRewarded *rewardedAd;
@property (nonatomic, strong) BDMBannerView *adView;
@property (nonatomic, strong) BDMNativeAd *nativeAd;

@property (nonatomic, strong) ALBidMachineMediationAdapterInterstitialAdDelegate *interstitialAdapterDelegate;
@property (nonatomic, strong) ALBidMachineMediationAdapterRewardedAdDelegate *rewardedAdapterDelegate;
@property (nonatomic, strong) ALBidMachineMediationAdapterAdViewDelegate *adViewAdapterDelegate;
@property (nonatomic, strong) ALBidMachineMediationAdapterNativeAdDelegate *nativeAdAdapterDelegate;

@end

@implementation ALBidMachineMediationAdapter

static NSObject *ALBMAdSettingsLock;
static ALAtomicBoolean              *ALBidMachineSDKInitialized;
static MAAdapterInitializationStatus ALBidMachineSDKInitializationStatus = NSIntegerMin;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALBMAdSettingsLock = [[NSObject alloc] init];
    ALBidMachineSDKInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods
- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters
               completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    
    [self updateAdSettingsWithParameters: parameters];
    
    if ( [ALBidMachineSDKInitialized compareAndSet: NO update: YES] )
    {
        NSString *sourceId = [parameters.serverParameters al_stringForKey: @"source_id"];
        
        if (sourceId == nil)
        {
            NSString *message = @"BidMachine source id cant't be nil";
            
            [self log: @"BidMachine SDK failed to finished initialization: %@", message];
            
            ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
            completionHandler(ALBidMachineSDKInitializationStatus, message);
            return;
        }
        
        ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializing;
        void (^bidmachineCompletionHandler)(void) = ^{
            
            [self log: @"BidMachine SDK successfully finished initialization"];
            
            ALBidMachineSDKInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
            completionHandler(ALBidMachineSDKInitializationStatus, nil);
        };
        
        [self log: @"Initializing BidMachine SDK with source id: %@", sourceId];
        
        BDMSdkConfiguration *config = [BDMSdkConfiguration new];
        [BDMSdk.sharedSdk startSessionWithSellerID:sourceId
                                     configuration:config
                                        completion:bidmachineCompletionHandler];
    }
    else
    {
        [self log: @"BidMachine attempted initialization already - marking initialization as %ld", ALBidMachineSDKInitializationStatus];
        
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
    self.rewardedAd = nil;

    self.adView.delegate = nil;
    self.adView = nil;
    self.adViewAdapterDelegate = nil;
    
    [self.nativeAd unregisterViews];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
    self.nativeAdAdapterDelegate = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters
                          andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *signal = BDMSdk.sharedSdk.biddingToken;
    [delegate didCollectSignal: signal];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters
                              andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading bidding interstitial ad..."];
    
    self.interstitialAd = [[BDMInterstitial alloc] init];
    self.interstitialAdapterDelegate = [[ALBidMachineMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter:self andNotify: delegate];
    self.interstitialAd.delegate = self.interstitialAdapterDelegate;
    
    [self.interstitialAd populateWithRequest:({
        BDMInterstitialRequest *request = BDMInterstitialRequest.new;
        request.bidPayload = parameters.bidResponse;
        request;
    })];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters
                              andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing bidding interstitial ad..."];
    
    if ([self.interstitialAd canShow])
    {
        UIViewController *presentingViewController = [ALBidMachineMediationAdapter presentingViewControllerFromParameters:parameters];
        [self.interstitialAd presentFromRootViewController:presentingViewController];
    }
    else
    {
        [self log: @"Unable to show bidding interstitial ad: ad is not valid - marking as expired"];
        
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adExpiredError];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading bidding rewarded ad..."];
    
    self.rewardedAd = [[BDMRewarded alloc] init];
    self.rewardedAdapterDelegate = [[ALBidMachineMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter:self andNotify: delegate];
    self.rewardedAd.delegate = self.rewardedAdapterDelegate;
    
    [self.rewardedAd populateWithRequest:({
        BDMRewardedRequest *request = BDMRewardedRequest.new;
        request.bidPayload = parameters.bidResponse;
        request;
    })];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    
    [self log: @"Showing bidding rewarded ad..."];
    
    if ([self.rewardedAd canShow])
    {
        UIViewController *presentingViewController = [ALBidMachineMediationAdapter presentingViewControllerFromParameters:parameters];
        [self.rewardedAd presentFromRootViewController:presentingViewController];
    }
    else
    {
        [self log: @"Unable to show bidding rewarded ad: ad is not valid - marking as expired"];
        
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adExpiredError];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                         adFormat:(MAAdFormat *)adFormat
                        andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading bidding banner ad..."];
    
    BDMBannerAdSize size = [self BMAdSizeFromAdFormat:adFormat];
    
    self.adView = [[BDMBannerView alloc] initWithFrame:(CGRect){.size = CGSizeFromBDMSize(size)}];
    self.adViewAdapterDelegate = [[ALBidMachineMediationAdapterAdViewDelegate alloc] initWithParentAdapter:self
                                                                                                    format:adFormat
                                                                                                 andNotify:delegate];
    
    
    
    self.adView.delegate = self.adViewAdapterDelegate;
    self.adView.producerDelegate = self.adViewAdapterDelegate;
    self.adView.rootViewController = [ALBidMachineMediationAdapter presentingViewControllerFromParameters:parameters];
    
    [self.adView populateWithRequest:({
        BDMBannerRequest *request = BDMBannerRequest.new;
        request.adSize = size;
        request.bidPayload = parameters.bidResponse;
        request;
    })];
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    [self log: @"Loading bidding native ad..."];
    
    self.nativeAd = [[BDMNativeAd alloc] init];
    self.nativeAdAdapterDelegate = [[ALBidMachineMediationAdapterNativeAdDelegate alloc] initWithParentAdapter:self
                                                                                                    parameters:parameters
                                                                                                     andNotify:delegate];
    self.nativeAd.delegate = self.nativeAdAdapterDelegate;
    self.nativeAd.producerDelegate = self.nativeAdAdapterDelegate;
    
    [self.nativeAd makeRequest:({
        BDMNativeAdRequest *request = BDMNativeAdRequest.new;
        request.bidPayload = parameters.bidResponse;
        request;
    })];
}

#pragma mark - Shared Methods

- (void)updateAdSettingsWithParameters:(id<MAAdapterParameters>)parameters
{
    @synchronized ( ALBMAdSettingsLock )
    {
        NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
        if ( isAgeRestrictedUser )
        {
            BDMSdk.sharedSdk.restrictions.coppa = isAgeRestrictedUser.boolValue;
        }
        
        if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
        {
            NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
            BDMSdk.sharedSdk.restrictions.subjectToGDPR = YES;
            if (hasUserConsent) {
                BDMSdk.sharedSdk.restrictions.hasConsent = hasUserConsent.boolValue;
            }
        }
        else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
        {
            BDMSdk.sharedSdk.restrictions.subjectToGDPR = NO;
        }
    }
}

- (nullable NSNumber *)privacySettingForSelector:(SEL)selector fromParameters:(id<MAAdapterParameters>)parameters
{
    // Use reflection because compiled adapters have trouble fetching `BOOL` from old SDKs and `NSNumber` from new SDKs (above 6.14.0)
    NSMethodSignature *signature = [[parameters class] instanceMethodSignatureForSelector: selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setSelector: selector];
    [invocation setTarget: parameters];
    [invocation invoke];
    
    // Privacy parameters return nullable `NSNumber` on newer SDKs
    if ( ALSdk.versionCode >= 6140000 )
    {
        NSNumber *__unsafe_unretained value;
        [invocation getReturnValue: &value];
        
        return value;
    }
    // Privacy parameters return BOOL on older SDKs
    else
    {
        BOOL rawValue;
        [invocation getReturnValue: &rawValue];
        
        return @(rawValue);
    }
}

- (BDMBannerAdSize)BMAdSizeFromAdFormat:(MAAdFormat *)adFormat
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

+ (UIViewController *)presentingViewControllerFromParameters:(id<MAAdapterResponseParameters>)parameters {
    UIViewController *presentingViewController;
    if ( ALSdk.versionCode >= 11020199 )
    {
        presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    }
    else
    {
        presentingViewController = [ALUtils topViewControllerFromKeyWindow];
    }
    return presentingViewController;
}

+ (MAAdapterError *)toMaxError:(NSError *)bidmachineError
{
    NSInteger bidmachineErrorCode = bidmachineError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    
    switch ( bidmachineErrorCode )
    {
        case BDMErrorCodeNoConnection:
            adapterError = MAAdapterError.noConnection;
            break;
        case BDMErrorCodeBadContent:
            adapterError = MAAdapterError.noFill;
            break;
        case BDMErrorCodeTimeout:
            adapterError = MAAdapterError.timeout;
            break;
        case BDMErrorCodeNoContent:
            adapterError = MAAdapterError.noFill;
            break;
        case BDMErrorCodeException:
            adapterError = MAAdapterError.invalidLoadState;
            break;
        case BDMErrorCodeWasExpired:
            adapterError = MAAdapterError.adExpiredError;
            break;
        case BDMErrorCodeInternal:
            adapterError = MAAdapterError.internalError;
            break;
        case BDMErrorCodeUsedAlready:
            adapterError = MAAdapterError.invalidLoadState;
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
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: bidmachineErrorCode
               thirdPartySdkErrorMessage: bidmachineError.localizedDescription];
#pragma clang diagnostic pop
}

@end

@implementation MABidMachineNativeAd

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if (self)
    {
        self.parentAdapter = parentAdapter;
        self.parameters = parameters;
    }
    return self;
}

- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView
{
    
    if ( !self.parentAdapter.nativeAd )
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
    
    UIViewController *presentingViewController = [ALBidMachineMediationAdapter presentingViewControllerFromParameters:self.parameters];
    MABidMachineNativeAdRendering *adRendering = [[MABidMachineNativeAdRendering alloc] initWithNativeAdView:maxNativeAdView];
    [self.parentAdapter.nativeAd presentOn:maxNativeAdView
                            clickableViews:clickableViews
                               adRendering:adRendering
                                controller:presentingViewController
                                     error:nil];
    
}

@end

@implementation MABidMachineNativeAdRendering

- (instancetype)initWithNativeAdView:(MANativeAdView *)adView
{
    self = [super init];
    if (self)
    {
        self.adView = adView;
    }
    return self;
}

- (nonnull UILabel *)callToActionLabel
{
    return self.adView.callToActionButton.titleLabel;
}

- (nonnull UILabel *)descriptionLabel
{
    return self.adView.bodyLabel;
}

- (nonnull UILabel *)titleLabel
{
    return self.adView.titleLabel;
}

- (nonnull UIImageView *)iconView
{
    return self.adView.iconImageView;
}

- (nonnull UIView *)mediaContainerView
{
    return self.adView.mediaContentView;
}

@end

@implementation ALBidMachineMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedToPresentWithError:(nonnull NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayInterstitialAdWithError:adapterError];
}

- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedWithError:(nonnull NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Interstitial failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)interstitialDidDismiss:(nonnull BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialReadyToPresent:(nonnull BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialRecieveUserInteraction:(nonnull BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)interstitialWillPresent:(nonnull BDMInterstitial *)interstitial
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

@end

@implementation ALBidMachineMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)rewarded:(nonnull BDMRewarded *)rewarded failedToPresentWithError:(nonnull NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to present ad with error: %@", adapterError];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
}

- (void)rewarded:(nonnull BDMRewarded *)rewarded failedWithError:(nonnull NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Rewarded failed to load ad with error: %@", adapterError];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)rewardedDidDismiss:(nonnull BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)rewardedFinishRewardAction:(nonnull BDMRewarded *)rewarded
{
    MAReward *reward = [self.parentAdapter reward];
    [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
    [self.delegate didRewardUserWithReward: reward];
}

- (void)rewardedReadyToPresent:(nonnull BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedRecieveUserInteraction:(nonnull BDMRewarded *)rewarded
{
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)rewardedWillPresent:(nonnull BDMRewarded *)rewarded {
    [self.parentAdapter log: @"Rewarded ad shown"];
    [self.delegate didDisplayRewardedAd];
}

@end

@implementation ALBidMachineMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                               format:(MAAdFormat *)format
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.format = format;
    }
    return self;
}

- (void)bannerView:(nonnull BDMBannerView *)bannerView failedWithError:(nonnull NSError *)error
{
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Banner failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewReadyToPresent:(nonnull BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"Banner loaded"];
    [self.delegate didLoadAdForAdView: bannerView];
}

- (void)bannerViewRecieveUserInteraction:(nonnull BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"Banner clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewWillPresentScreen:(nonnull BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"Banner start handling click"];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewDidDismissScreen:(nonnull BDMBannerView *)bannerView
{
    [self.parentAdapter log: @"Banner finished handling click"];
    [self.delegate didCollapseAdViewAd];
}

- (void)didProduceImpression:(nonnull id<BDMAdEventProducer>)producer
{
    [self.parentAdapter log: @"Banner shown"];
    [self.delegate didDisplayAdViewAd];
}

- (void)didProduceUserAction:(nonnull id<BDMAdEventProducer>)producer
{
    
}

@end

@implementation ALBidMachineMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALBidMachineMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.parameters = parameters;
    }
    return self;
}

- (void)nativeAd:(nonnull BDMNativeAd *)nativeAd readyToPresentAd:(nonnull BDMAuctionInfo *)auctionInfo
{
    [self.parentAdapter log: @"Native ad loaded"];
    [self renderNativeAd: nativeAd];
}

- (void)nativeAd:(nonnull BDMNativeAd *)nativeAd failedWithError:(nonnull NSError *)error {
    MAAdapterError *adapterError = [ALBidMachineMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)didProduceUserAction:(nonnull id<BDMAdEventProducer>)producer {
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)didProduceImpression:(nonnull id<BDMAdEventProducer>)producer {
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)renderNativeAd:(BDMNativeAd *)nativeAd {
    if ( !nativeAd ) {
        [self.parentAdapter log: @"Native ad cant't be nill"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
        return;
    }
    
    if (![nativeAd canShow]) {
        [self.parentAdapter log: @"Native ad not ready to show"];
        [self.delegate didFailToLoadNativeAdWithError: MAAdapterError.adExpiredError];
        return;
    }
    
    dispatchOnMainQueue(^{
        MANativeAd *maxNativeAd = [[MABidMachineNativeAd alloc] initWithParentAdapter:self.parentAdapter
                                                                           parameters:self.parameters
                                                                         builderBlock:^(MANativeAdBuilder *builder) {
            builder.title = nativeAd.title;
            builder.body = nativeAd.body;
            builder.callToAction = nativeAd.CTAText;
            
            if (nativeAd.iconUrl) {
                builder.icon = [[MANativeAdImage alloc] initWithURL:[NSURL URLWithString:nativeAd.iconUrl]];
            }
        }];
        
        [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
    });
}

@end


