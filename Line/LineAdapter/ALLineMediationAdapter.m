//
//  ALLineMediationAdapter.h
//  AppLovinSDK
//
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALLineMediationAdapter.h"
#import <FiveAd/FiveAd.h>

#define ADAPTER_VERSION @"2.9.20250805.0"

@interface ALLineMediationAdapterInterstitialAdDelegate : NSObject <FADInterstitialEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterRewardedAdDelegate : NSObject <FADVideoRewardEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterAdViewDelegate : NSObject <FADCustomLayoutEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) MAAdFormat *adFormat;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterNativeAdViewDelegate : NSObject <FADNativeEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@property (nonatomic, strong) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALLineMediationAdapterNativeAdDelegate : NSObject <FADNativeEventListener>
@property (nonatomic,   weak) ALLineMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;
@end

@interface MALineNativeAd : MANativeAd
@property (nonatomic, weak) ALLineMediationAdapter *parentAdapter;
- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;
@end

@interface ALLineMediationAdapter ()

@property (nonatomic, strong) FADAdLoader *adLoader;

// Interstitial
@property (nonatomic, strong) ALLineMediationAdapterInterstitialAdDelegate *interstitialDelegate;
@property (nonatomic, strong) FADInterstitial *interstitialAd;

// Rewarded
@property (nonatomic, strong) ALLineMediationAdapterRewardedAdDelegate *rewardedDelegate;
@property (nonatomic, strong) FADVideoReward *rewardedAd;

// AdView
@property (nonatomic, strong) ALLineMediationAdapterAdViewDelegate *adViewDelegate;
@property (nonatomic, strong) ALLineMediationAdapterNativeAdViewDelegate *nativeAdViewDelegate;
@property (nonatomic, strong) FADAdViewCustomLayout *adView;

// Native
@property (nonatomic, strong) ALLineMediationAdapterNativeAdDelegate *nativeAdDelegate;
@property (nonatomic, strong) FADNative *nativeAd;

@end

@implementation ALLineMediationAdapter

static ALAtomicBoolean *ALLineInitialized;

+ (void)initialize
{
    [super initialize];
    
    ALLineInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (NSString *)SDKVersion
{
    return [FADSettings semanticVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (void)destroy
{
    [self.interstitialAd setEventListener: nil];
    self.interstitialAd = nil;
    self.interstitialDelegate.delegate = nil;
    self.interstitialDelegate = nil;
    
    [self.rewardedAd setEventListener: nil];
    self.rewardedAd = nil;
    self.rewardedDelegate.delegate = nil;
    self.rewardedDelegate = nil;
    
    [self.adView setEventListener: nil];
    self.adView = nil;
    self.adViewDelegate.delegate = nil;
    self.adViewDelegate = nil;
    self.nativeAdViewDelegate.delegate = nil;
    self.nativeAdViewDelegate = nil;
    
    [self.nativeAd setEventListener: nil];
    self.nativeAd = nil;
    self.nativeAdDelegate.delegate = nil;
    self.nativeAdDelegate = nil;
    
    self.adLoader = nil;
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    [self log: @"Collecting signal..."];
    
    NSString *adUnitId = parameters.adUnitIdentifier;
    if ( ![adUnitId al_isValidString] )
    {
        NSString *errorMessage = @"invalid ad unit id";
        [self log: @"Signal collection failed with error: %@", errorMessage];
        [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
        
        return;
    }
    
    NSDictionary<NSString *, NSString *> *credentials = parameters.serverParameters[@"placement_ids"] ?: @{};
    NSString *slotId = credentials[adUnitId];
    if ( ![slotId al_isValidString] )
    {
        NSString *errorMessage = @"invalid slot id ";
        [self log: @"Signal collection failed with error: %@", errorMessage];
        [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
        
        return;
    }
    
    self.adLoader = [self retrieveAdLoader: parameters];
    
    [self.adLoader collectSignalWithSlotId: slotId withSignalCallback:^(NSString *_Nullable token, NSError *_Nullable error) {
        
        if ( error )
        {
            [self log: @"Signal collection failed with error: %@", error];
            [delegate didFailToCollectSignalWithErrorMessage: error.localizedDescription];
            
            return;
        }
        
        if ( ![token al_isValidString] )
        {
            NSString *errorMessage = @"Unexpected error - token is nil";
            [self log: @"Signal collection failed with error: %@", errorMessage];
            [delegate didFailToCollectSignalWithErrorMessage: errorMessage];
            
            return;
        }
        
        [self log: @"Signal collection successful"];
        [delegate didCollectSignal: token];
    }];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBidding = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@interstitial ad for slot id: %@...", (isBidding ? @"bidding " : @""), slotId];
    
    void (^interstitialLoadCallback)(FADInterstitial *_Nullable, NSError *_Nullable) = ^(FADInterstitial *_Nullable ad, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALLineMediationAdapter toMaxError: error.code];
            [self log: @"Interstitial ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadInterstitialAdWithError: adapterError];
            
            return;
        }
        
        if ( !ad )
        {
            [self log: @"Interstitial ad (%@) NO FILL'd", ad.slotId];
            [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
            
            return;
        }
        
        self.interstitialAd = ad;
        
        [self log: @"Interstitial ad loaded"];
        [delegate didLoadInterstitialAd];
    };
    
    self.adLoader = [self retrieveAdLoader: parameters];
    
    if ( isBidding )
    {
        FADBidData *bidData = [[FADBidData alloc] initWithBidResponse: parameters.bidResponse withWatermark: nil];
        [self.adLoader loadInterstitialAdWithBidData: bidData withLoadCallback: interstitialLoadCallback];
    }
    else
    {
        FADAdSlotConfig *slotConfig = [FADAdSlotConfig configWithSlotId: slotId];
        [self.adLoader loadInterstitialAdWithConfig: slotConfig withLoadCallback: interstitialLoadCallback];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad for slot id: %@...", slotId];
    
    if ( !self.interstitialAd )
    {
        [self log: @"Interstitial ad failed to show for slot id: %@ - no ad loaded", slotId];
        [delegate didFailToDisplayInterstitialAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                        mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                     mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        
        return;
        
    }
    
    self.interstitialDelegate = [[ALLineMediationAdapterInterstitialAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [self.interstitialAd setEventListener: self.interstitialDelegate];
    
    [self.interstitialAd showWithViewController: parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBidding = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@rewarded ad for slot id: %@...", (isBidding ? @"bidding " : @""), slotId];
    
    void (^rewardedLoadCallback)(FADVideoReward *_Nullable, NSError *_Nullable) = ^(FADVideoReward *_Nullable ad, NSError *_Nullable error) {
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALLineMediationAdapter toMaxError: error.code];
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
        
        self.rewardedAd = ad;
        
        [self log: @"Rewarded ad loaded"];
        [delegate didLoadRewardedAd];
    };
    
    self.adLoader = [self retrieveAdLoader: parameters];
    
    if ( isBidding )
    {
        FADBidData *bidData = [[FADBidData alloc] initWithBidResponse: parameters.bidResponse withWatermark: nil];
        [self.adLoader loadRewardAdWithBidData: bidData withLoadCallback: rewardedLoadCallback];
    }
    else
    {
        FADAdSlotConfig *slotConfig = [FADAdSlotConfig configWithSlotId: slotId];
        [self.adLoader loadRewardAdWithConfig: slotConfig withLoadCallback: rewardedLoadCallback];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing rewarded ad for slot id: %@...", slotId];
    
    if ( !self.rewardedAd )
    {
        [self log: @"Rewarded ad failed to show for slot id: %@ - no ad loaded", slotId];
        [delegate didFailToDisplayRewardedAdWithError: [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                                                    mediatedNetworkErrorCode: MAAdapterError.adNotReady.code
                                                                 mediatedNetworkErrorMessage: MAAdapterError.adNotReady.message]];
        
        return;
    }
    
    self.rewardedDelegate = [[ALLineMediationAdapterRewardedAdDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    [self.rewardedAd setEventListener: self.rewardedDelegate];
    
    [self configureRewardForParameters: parameters];
    
    [self.rewardedAd showWithViewController: parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow]];
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    BOOL isNative = [parameters.serverParameters al_boolForKey: @"is_native"];
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *bidResponse = parameters.bidResponse;
    BOOL isBidding = [bidResponse al_isValidString];
    
    [self log: @"Loading %@%@%@ ad for slot id: %@...", (isNative ? @"native " : @""), (isBidding ? @"bidding " : @""), adFormat.label, slotId];
    
    dispatchOnMainQueue(^{
        
        if ( isNative )
        {
            void (^nativeAdViewLoadCallback)(FADNative *_Nullable, NSError *_Nullable) = ^(FADNative *_Nullable ad, NSError *_Nullable error) {
                
                if ( error )
                {
                    MAAdapterError *adapterError = [ALLineMediationAdapter toMaxError: error.code];
                    [self log: @"Native %@ ad failed to load with error: %@", adFormat.label, adapterError];
                    [delegate didFailToLoadAdViewAdWithError: adapterError];
                    
                    return;
                }
                
                if ( !ad )
                {
                    [self log: @"Native %@ ad (%@) NO FILL'd", adFormat.label, slotId];
                    [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
                    
                    return;
                }
                
                self.nativeAdViewDelegate = [[ALLineMediationAdapterNativeAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                             adFormat: adFormat
                                                                                                     serverParameters: parameters.serverParameters
                                                                                                            andNotify: delegate];
                self.nativeAd = ad;
                [self.nativeAd setEventListener: self.nativeAdViewDelegate];
                
                // We always want to mute banners and MRECs
                [self.nativeAd enableSound: NO];
                
                [self renderCustomNativeBanner: adFormat serverParameters: parameters.serverParameters andNotify: delegate];
            };
            
            self.adLoader = [self retrieveAdLoader: parameters];
            
            if ( isBidding )
            {
                FADBidData *bidData = [[FADBidData alloc] initWithBidResponse: bidResponse withWatermark: nil];
                [self.adLoader loadNativeAdWithBidData: bidData withInitialWidth: adFormat.size.width withLoadCallback: nativeAdViewLoadCallback];
            }
            else
            {
                FADAdSlotConfig *slotConfig = [FADAdSlotConfig configWithSlotId: slotId];
                [self.adLoader loadNativeAdWithConfig: slotConfig withInitialWidth: adFormat.size.width withLoadCallback: nativeAdViewLoadCallback];
            }
        }
        else
        {
            void (^adViewLoadCallback)(FADAdViewCustomLayout *_Nullable, NSError *_Nullable) = ^(FADAdViewCustomLayout *_Nullable ad, NSError *_Nullable error) {
                
                if ( error )
                {
                    MAAdapterError *adapterError = [ALLineMediationAdapter toMaxError: error.code];
                    [self log: @"%@ ad failed to load with error: %@", adFormat.label, adapterError];
                    [delegate didFailToLoadAdViewAdWithError: adapterError];
                    
                    return;
                }
                
                if ( !ad )
                {
                    [self log: @"%@ ad (%@) NO FILL'd", adFormat.label, slotId];
                    [delegate didFailToLoadAdViewAdWithError: MAAdapterError.noFill];
                    
                    return;
                }
                
                self.adViewDelegate = [[ALLineMediationAdapterAdViewDelegate alloc] initWithParentAdapter: self
                                                                                                 adFormat: adFormat
                                                                                                andNotify: delegate];
                
                self.adView = ad;
                [self.adView setEventListener: self.adViewDelegate];
                self.adView.frame = CGRectMake(0, 0, adFormat.size.width, adFormat.size.height);
                
                // We always want to mute banners and MRECs
                [self.adView enableSound: NO];
                
                [self log: @"%@ ad loaded", adFormat.label];
                [delegate didLoadAdForAdView: self.adView];
            };
            
            self.adLoader = [self retrieveAdLoader: parameters];
            
            if ( isBidding )
            {
                FADBidData *bidData = [[FADBidData alloc] initWithBidResponse: bidResponse withWatermark: nil];
                [self.adLoader loadBannerAdWithBidData: bidData withInitialWidth: adFormat.size.width withLoadCallback: adViewLoadCallback];
            }
            else
            {
                FADAdSlotConfig *slotConfig = [FADAdSlotConfig configWithSlotId: slotId];
                [self.adLoader loadBannerAdWithConfig: slotConfig withInitialWidth: adFormat.size.width withLoadCallback: adViewLoadCallback];
            }
        }
    });
}

#pragma mark - MANativeAdAdapter Methods

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    BOOL isBidding = [parameters.bidResponse al_isValidString];
    [self log: @"Loading %@native ad for slot id: %@...", (isBidding ? @"bidding " : @""), slotId];
    
    void (^nativeLoadCallback)(FADNative *_Nullable, NSError *_Nullable) = ^(FADNative *_Nullable loadedNativeAd, NSError *_Nullable error) {
        
        [self log: @"Native ad loaded"];
        
        if ( error )
        {
            MAAdapterError *adapterError = [ALLineMediationAdapter toMaxError: error.code];
            [self log: @"Native ad failed to load with error: %@", adapterError];
            [delegate didFailToLoadNativeAdWithError: adapterError];
            
            return;
        }
        
        if ( !loadedNativeAd )
        {
            [self log: @"Native ad (%@) NO FILL'd", slotId];
            [delegate didFailToLoadNativeAdWithError: MAAdapterError.noFill];
            
            return;
        }
        
        NSString *templateName = [parameters.serverParameters al_stringForKey: @"template" defaultValue: @""];
        BOOL isTemplateAd = [templateName al_isValidString];
        if ( isTemplateAd && ![loadedNativeAd.getAdTitle al_isValidString] )
        {
            [self e: @"Native ad (%@) does not have required assets.", loadedNativeAd];
            [delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
            
            return;
        }
        
        [loadedNativeAd loadIconImageAsyncWithBlock:^(UIImage *iconImage) {
            // Ensure UI rendering is done on main queue
            dispatchOnMainQueue(^{
                
                FADNative *nativeAd = self.nativeAd;
                if ( !nativeAd )
                {
                    [self log: @"Native ad destroyed before assets finished load"];
                    [delegate didFailToLoadNativeAdWithError: MAAdapterError.invalidLoadState];
                    
                    return;
                }
                
                MANativeAd *maxNativeAd = [[MALineNativeAd alloc] initWithParentAdapter: self builderBlock:^(MANativeAdBuilder *builder) {
                    builder.title = nativeAd.getAdTitle;
                    builder.advertiser = nativeAd.getAdvertiserName;
                    builder.body = nativeAd.getDescriptionText;
                    builder.callToAction = nativeAd.getButtonText;
                    builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                    builder.mediaView = nativeAd.getAdMainView;
                }];
                
                [delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: nil];
            });
        }];
        
        self.nativeAdDelegate = [[ALLineMediationAdapterNativeAdDelegate alloc] initWithParentAdapter: self
                                                                                     serverParameters: parameters.serverParameters
                                                                                            andNotify: delegate];
        self.nativeAd = loadedNativeAd;
        [self.nativeAd setEventListener: self.nativeAdDelegate];
        
        // We always want to mute banners and MRECs
        [self.nativeAd enableSound: NO];
    };
    
    self.adLoader = [self retrieveAdLoader: parameters];
    
    if ( isBidding )
    {
        FADBidData *bidData = [[FADBidData alloc] initWithBidResponse: parameters.bidResponse withWatermark: nil];
        [self.adLoader loadNativeAdWithBidData: bidData withLoadCallback: nativeLoadCallback];
    }
    else
    {
        FADAdSlotConfig *slotConfig = [FADAdSlotConfig configWithSlotId: slotId];
        [self.adLoader loadNativeAdWithConfig: slotConfig withInitialWidth: CGRectGetWidth([UIScreen mainScreen].bounds) withLoadCallback: nativeLoadCallback];
    }
}

#pragma mark - Shared Methods

- (FADAdLoader *)retrieveAdLoader:(id<MAAdapterParameters>)parameters
{
    NSError *error;
    FADConfig *config = [self configFromParameters: parameters];
    FADAdLoader *adLoader = [FADAdLoader adLoaderForConfig: config outError: &error];
    
    if ( error )
    {
        [NSException raise: NSInvalidArgumentException format: @"Failed to retrieve ad loader for ad unit id: %@, with error: %@", parameters.adUnitIdentifier, error.localizedDescription];
    }
    
    return adLoader;
}

- (FADConfig *)configFromParameters:(id<MAAdapterParameters>)parameters
{
    NSString *appId = [parameters.serverParameters al_stringForKey: @"app_id"];
    
    FADConfig *config = [[FADConfig alloc] initWithAppId: appId];
    config.isTest = [parameters isTesting];
    
    [self updateMuteStateFromServerParameters: parameters.serverParameters forConfig: config];
    
    //
    // GDPR options
    //
    NSNumber *hasUserConsent = [parameters hasUserConsent];
    if ( hasUserConsent != nil )
    {
        config.needGdprNonPersonalizedAdsTreatment = hasUserConsent.boolValue ? kFADNeedGdprNonPersonalizedAdsTreatmentFalse : kFADNeedGdprNonPersonalizedAdsTreatmentTrue;
    }
    
    return config;
}

- (void)updateMuteStateFromServerParameters:(NSDictionary<NSString *, id> *)serverParameters forConfig:(FADConfig *)config
{
    if ( [serverParameters al_containsValueForKey: @"is_muted"] )
    {
        [config enableSoundByDefault: ![serverParameters al_numberForKey: @"is_muted"].boolValue];
    }
}

+ (MAAdapterError *)toMaxError:(FADErrorCode)lineAdsErrorCode
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    NSString *thirdPartySdkErrorMessage;
    switch ( lineAdsErrorCode )
    {
        case kFADErrorNetworkError:
            adapterError = MAAdapterError.noConnection;
            thirdPartySdkErrorMessage = @"Please try again in a stable network environment.";
            break;
        case kFADErrorCodeNoAd:
            adapterError = MAAdapterError.noFill;
            thirdPartySdkErrorMessage = @"Ad was not ready at display time. Please try again.";
            break;
        case kFADErrorBadAppId:
        case kFADErrorCodeFormatMismatch:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"Check if the OS type, PackageName, and issued AppID registered in FIVE Dashboard and the application settings match. Please be careful about blanks.";
            break;
        case kFADErrorStorageError:
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"There is a problem with the device storage. Please try again with another device.";
            break;
        case kFADErrorInternalError:
            adapterError = MAAdapterError.internalError;
            thirdPartySdkErrorMessage = @"Unspecified.";
            break;
        case kFADErrorInvalidState:
            adapterError = MAAdapterError.invalidLoadState;
            thirdPartySdkErrorMessage = @"There is a problem with the implementation. Please check the following. Whether the initialization process ([FADSettings registerConfig: config]) is executed before the creation of the ad object or loadAdAsync. Are you calling loadAdAsync multiple times for one ad object?";
            break;
        case kFADErrorBadSlotId:
            adapterError = MAAdapterError.invalidConfiguration;
            thirdPartySdkErrorMessage = @"Make sure you are using the SlotID issued on the FIVE Dashboard.";
            break;
        case kFADErrorSuppressed:
        case kFADErrorPlayerError:
        case kFADErrorNone:
            adapterError = MAAdapterError.unspecified;
            thirdPartySdkErrorMessage = @"Unspecified.";
            break;
    }
    
    return [MAAdapterError errorWithAdapterError: adapterError
                        mediatedNetworkErrorCode: lineAdsErrorCode
                     mediatedNetworkErrorMessage: thirdPartySdkErrorMessage];
}

- (void)renderCustomNativeBanner:(MAAdFormat *)adFormat serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self.nativeAd loadIconImageAsyncWithBlock:^(UIImage *iconImage) {
        // Ensure UI rendering is done on main queue
        dispatchOnMainQueue(^{
            
            FADNative *nativeAd = self.nativeAd;
            if ( !nativeAd )
            {
                [self log: @"Ad destroyed before assets finished load"];
                [delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidLoadState];
                
                return;
            }
            
            MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: adFormat builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = nativeAd.getAdTitle;
                builder.body = nativeAd.getDescriptionText;
                builder.callToAction = nativeAd.getButtonText;
                builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                builder.mediaView = nativeAd.getAdMainView;
            }];
            
            // Backend will pass down `vertical` as the template to indicate using a vertical native template
            NSString *templateName = [serverParameters al_stringForKey: @"template" defaultValue: @""];
            if ( [templateName containsString: @"vertical"] && ALSdk.versionCode < 6140500 )
            {
                [self log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
            }
            
            MANativeAdView *maxNativeAdView;
            // Fallback case to be removed when backend sends down full template names for vertical native ads
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
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
            if ( maxNativeAd.icon && maxNativeAdView.iconImageView )
            {
                [clickableViews addObject: maxNativeAdView.iconImageView];
            }
            if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
            {
                [clickableViews addObject: maxNativeAdView.mediaContentView];
            }
            
            [nativeAd registerViewForInteraction: maxNativeAdView withInformationIconView: maxNativeAdView.iconImageView withClickableViews: clickableViews];
            [delegate didLoadAdForAdView: maxNativeAdView];
        });
    }];
}

@end

@implementation ALLineMediationAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)fiveInterstitialAd:(FADInterstitial *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Interstitial ad failed to show for slot id: %@ with error: %ld", ad.slotId, errorCode];
    
    MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                         mediatedNetworkErrorCode: errorCode
                                      mediatedNetworkErrorMessage: @""];
    
    [self.delegate didFailToDisplayInterstitialAdWithError: error];
}
- (void)fiveInterstitialAdDidImpression:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayInterstitialAd];
}

- (void)fiveInterstitialAdDidClick:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickInterstitialAd];
}

- (void)fiveInterstitialAdFullScreenDidOpen:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad shown for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdFullScreenDidClose:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad hidden for slot id: %@...", ad.slotId];
    [self.delegate didHideInterstitialAd];
}

- (void)fiveInterstitialAdDidPlay:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdDidPause:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveInterstitialAdDidViewThrough:(FADInterstitial *)ad
{
    [self.parentAdapter log: @"Interstitial ad completed for slot id: %@...", ad.slotId];
}

@end

@implementation ALLineMediationAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)fiveVideoRewardAd:(FADVideoReward *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Rewarded ad failed to show for slot id: %@ with error: %ld", ad.slotId, errorCode];
    
    MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                         mediatedNetworkErrorCode: errorCode
                                      mediatedNetworkErrorMessage: @""];
    
    [self.delegate didFailToDisplayRewardedAdWithError: error];
}

- (void)fiveVideoRewardAdDidImpression:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayRewardedAd];
}

- (void)fiveVideoRewardAdDidClick:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickRewardedAd];
}

- (void)fiveVideoRewardAdFullScreenDidClose:(FADVideoReward *)ad
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = self.parentAdapter.reward;
        
        [self.parentAdapter log: @"Rewarded ad user with reward: %@ for slot id: %@...", reward, ad.slotId];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded ad hidden for slot id: %@...", ad.slotId];
    [self.delegate didHideRewardedAd];
}

- (void)fiveVideoRewardAdFullScreenDidOpen:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad shown for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidPlay:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidPause:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidViewThrough:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad completed for slot id: %@...", ad.slotId];
}

- (void)fiveVideoRewardAdDidReward:(FADVideoReward *)ad
{
    [self.parentAdapter log: @"Rewarded ad did reward user for slot id: %@...", ad.slotId];
    self.grantedReward = YES;
}

@end

@implementation ALLineMediationAdapterAdViewDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adFormat = adFormat;
    }
    return self;
}

- (void)fiveCustomLayoutAd:(FADAdViewCustomLayout *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"%@ ad failed to show for slot id: %@ with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    
    MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                         mediatedNetworkErrorCode: errorCode
                                      mediatedNetworkErrorMessage: @""];
    
    [self.delegate didFailToDisplayAdViewAdWithError: error];
}

- (void)fiveCustomLayoutAdDidImpression:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad impression tracked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)fiveCustomLayoutAdDidClick:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad clicked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)fiveCustomLayoutAdViewDidRemove:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad hidden for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didHideAdViewAd];
}

- (void)fiveCustomLayoutAdDidPlay:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad did play for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveCustomLayoutAdDidPause:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad did pause for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveCustomLayoutAdDidViewThrough:(FADAdViewCustomLayout *)ad
{
    [self.parentAdapter log: @"%@ ad completed for slot id: %@...", self.adFormat.label, ad.slotId];
}

@end

@implementation ALLineMediationAdapterNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter adFormat:(MAAdFormat *)adFormat serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.adFormat = adFormat;
        self.serverParameters = serverParameters;
    }
    return self;
}

- (void)fiveNativeAd:(FADNative *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native %@ ad showed for slot id: %@... with error: %ld", self.adFormat.label, ad.slotId, errorCode];
    
    MAAdapterError *error = [MAAdapterError errorWithAdapterError: MAAdapterError.adDisplayFailedError
                                         mediatedNetworkErrorCode: errorCode
                                      mediatedNetworkErrorMessage: @""];
    [self.delegate didFailToDisplayAdViewAdWithError: error];
}

- (void)fiveNativeAdDidImpression:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad impression tracked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didDisplayAdViewAd];
}

- (void)fiveNativeAdDidClick:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad clicked for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didClickAdViewAd];
}

- (void)fiveNativeAdViewDidRemove:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad hidden for slot id: %@...", self.adFormat.label, ad.slotId];
    [self.delegate didHideAdViewAd];
}

- (void)fiveNativeAdDidPlay:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad did play for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveNativeAdDidPause:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad did pause for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)fiveNativeAdDidViewThrough:(FADNative *)ad
{
    [self.parentAdapter log: @"Native %@ ad completed for slot id: %@...", self.adFormat.label, ad.slotId];
}

- (void)renderCustomNativeBanner
{
    [self.parentAdapter.nativeAd loadIconImageAsyncWithBlock:^(UIImage *iconImage) {
        // Ensure UI rendering is done on main queue
        dispatchOnMainQueue(^{
            
            FADNative *nativeAd = self.parentAdapter.nativeAd;
            if ( !nativeAd )
            {
                [self.parentAdapter log: @"Ad destroyed before assets finished load"];
                [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.invalidLoadState];
                
                return;
            }
            
            MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
                builder.title = nativeAd.getAdTitle;
                builder.body = nativeAd.getDescriptionText;
                builder.callToAction = nativeAd.getButtonText;
                builder.icon = [[MANativeAdImage alloc] initWithImage: iconImage];
                builder.mediaView = nativeAd.getAdMainView;
            }];
            
            // Backend will pass down `vertical` as the template to indicate using a vertical native template
            NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
            
            MANativeAdView *maxNativeAdView;
            // Fallback case to be removed when backend sends down full template names for vertical native ads
            if ( [templateName isEqualToString: @"vertical"] )
            {
                NSString *verticalTemplateName = ( self.adFormat == MAAdFormat.leader ) ? @"vertical_leader_template" : @"vertical_media_banner_template";
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: verticalTemplateName];
            }
            else
            {
                maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
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
            if ( maxNativeAd.icon && maxNativeAdView.iconImageView )
            {
                [clickableViews addObject: maxNativeAdView.iconImageView];
            }
            if ( maxNativeAd.mediaView && maxNativeAdView.mediaContentView )
            {
                [clickableViews addObject: maxNativeAdView.mediaContentView];
            }
            
            [nativeAd registerViewForInteraction: maxNativeAdView withInformationIconView: maxNativeAdView.iconImageView withClickableViews: clickableViews];
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        });
    }];
}

@end

@implementation ALLineMediationAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.serverParameters = serverParameters;
    }
    return self;
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native ad failed to load for slot id: %@ with error: %ld", ad.slotId, errorCode];
    MAAdapterError *error = [ALLineMediationAdapter toMaxError: errorCode];
    [self.delegate didFailToLoadNativeAdWithError: error];
}

- (void)fiveNativeAd:(FADNative *)ad didFailedToShowAdWithError:(FADErrorCode)errorCode
{
    [self.parentAdapter log: @"Native ad failed to show ad for slot id: %@... with error: %ld", ad.slotId, errorCode];
}

- (void)fiveNativeAdDidImpression:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad impression tracked for slot id: %@...", ad.slotId];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)fiveNativeAdDidClick:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad clicked for slot id: %@...", ad.slotId];
    [self.delegate didClickNativeAd];
}

- (void)fiveNativeAdViewDidRemove:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad hidden for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidPlay:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad did play for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidPause:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad did pause for slot id: %@...", ad.slotId];
}

- (void)fiveNativeAdDidViewThrough:(FADNative *)ad
{
    [self.parentAdapter log: @"Native ad completed for slot id: %@...", ad.slotId];
}

@end

@implementation MALineNativeAd

- (instancetype)initWithParentAdapter:(ALLineMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    FADNative *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    UIImageView *iconImageView = nil;
    for ( UIView *clickableView in clickableViews )
    {
        if( [clickableView isKindOfClass: [UIImageView class]] )
        {
            iconImageView = (UIImageView *)clickableView;
            break;
        }
    }
    
    [self.parentAdapter d: @"Preparing views for interaction: %@ with container: %@", clickableViews, container];
    
    [nativeAd registerViewForInteraction: container withInformationIconView: iconImageView withClickableViews: clickableViews];
    
    return YES;
}

@end
