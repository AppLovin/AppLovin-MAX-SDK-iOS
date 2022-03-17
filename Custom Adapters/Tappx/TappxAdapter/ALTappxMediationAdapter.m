//
//  ALTappxMediationAdapter.m
//  TappxAdapter
//
//  Created by Nana Amoah on 3/8/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALTappxMediationAdapter.h"
#import "TappxFramework/TappxAds.h"

#define ADAPTER_VERSION @"4.0.10.0"

/**
 * Interstitial Delegate
 */
@interface ALTappxInterstitialDelegate : NSObject<TappxInterstitialViewControllerDelegate>
@property (nonatomic,   weak) ALTappxMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALTappxMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

/**
 * AdView Delegate
 */
@interface ALTappxAdViewDelegate : NSObject<TappxBannerViewControllerDelegate>
@property (nonatomic,   weak) ALTappxMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALTappxMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@interface ALTappxMediationAdapter()

// Interstitial Properties
@property (nonatomic, strong) TappxInterstitialViewController *interstitialAd;
@property (nonatomic, strong) ALTappxInterstitialDelegate *interstitialAdDelegate;

// AdView Properties
@property (nonatomic, strong) TappxBannerViewController *adView;
@property (nonatomic, strong) ALTappxAdViewDelegate *adViewAdDelegate;
@property (nonatomic, strong) UIView *adViewContainer;

@property (nonatomic, weak) UIViewController *presentingViewController;

@end

@implementation ALTappxMediationAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    [self log: @"Initializing Tappx adapter... "];
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion
{
    return [TappxFramework versionSDK];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self log: @"Destroy called for adapter %@", self];
    
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    [self.adView removeBanner];
    self.adView = nil;
    self.adViewContainer = nil;
    self.adViewAdDelegate = nil;
}

#pragma mark - MAInterstitial Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial ad..."];
    
    self.interstitialAdDelegate = [[ALTappxInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialAd = [[TappxInterstitialViewController alloc] initWithDelegate: self.interstitialAdDelegate];
    
    [self.interstitialAd setAutoShowWhenReady: NO];
    [self.interstitialAd load];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad..."];
    
    if ( [self.interstitialAd isReady] )
    {
        if ( ALSdk.versionCode >= 11020199 )
        {
            self.presentingViewController = parameters.presentingViewController;
        }
        
        [self.interstitialAd show];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    [self log: @"Loading %@ ad view ad...", adFormat.label];
    
    self.adViewAdDelegate = [[ALTappxAdViewDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    
    self.adViewContainer = [[UIView alloc] init];
    self.adView = [[TappxBannerViewController alloc] initWithDelegate : self.adViewAdDelegate
                                                              andSize : [self sizeFromAdFormat: adFormat]
                                                              andView : self.adViewContainer];
    [self.adView load];
}

#pragma mark - Helper Methods

+ (MAAdapterError *)toMaxError:(TappxErrorAd *)tappxAdError
{
    TappxErrorCode tappxErrorCode = tappxAdError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( tappxErrorCode )
    {
        case DEVELOPER_ERROR:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case NO_CONNECTION:
            adapterError = MAAdapterError.noConnection;
            break;
        case NO_FILL:
            adapterError = MAAdapterError.noFill;
            break;
        case CANCELLED:
            adapterError = MAAdapterError.internalError;
            break;
        case SERVER_ERROR:
            adapterError = MAAdapterError.serverError;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.code
                             errorString: adapterError.message
                  thirdPartySdkErrorCode: tappxErrorCode
               thirdPartySdkErrorMessage: tappxAdError.description];
}

- (TappxBannerSize)sizeFromAdFormat:(MAAdFormat *)adFormat
{
    if ( adFormat == MAAdFormat.banner )
    {
        return TappxBannerSize320x50;
    }
    else if ( adFormat == MAAdFormat.leader )
    {
        return TappxBannerSize728x90;
    }
    else if ( adFormat ==  MAAdFormat.mrec )
    {
        return TappxBannerSize300x250;
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"Invalid ad format: %@", adFormat];
        return TappxBannerSize320x50;
    }
}

@end

#pragma mark - Interstitial Delegate

@implementation ALTappxInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALTappxMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (UIViewController *)presentViewController
{
    return self.parentAdapter.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
}

- (void)tappxInterstitialViewControllerDidFinishLoad:(TappxInterstitialViewController *)viewController
{
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)tappxInterstitialViewControllerDidFail:(TappxInterstitialViewController *)viewController withError:(TappxErrorAd *)error
{
    MAAdapterError *adapterError = [ALTappxMediationAdapter toMaxError: error];
    
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)tappxInterstitialViewControllerDidAppear:(TappxInterstitialViewController *)viewController
{
    [self.parentAdapter log: @"Interstitial ad shown"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)tappxInterstitialViewControllerDidPress:(TappxInterstitialViewController *)viewController
{
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)tappxInterstitialViewControllerDidClose:(TappxInterstitialViewController *)viewController
{
    [self.parentAdapter log: @"Interstitial ad hidden"];
    [self.delegate didHideInterstitialAd];
}

@end

@implementation ALTappxAdViewDelegate

- (instancetype)initWithParentAdapter:(ALTappxMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - TappxAdViewDelegate Methods

- (UIViewController *)presentViewController
{
    return [ALUtils topViewControllerFromKeyWindow];
}

- (void)tappxBannerViewControllerDidFinishLoad:(TappxBannerViewController *)viewController
{
    [self.parentAdapter log: @"AdView ad loaded"];
    [self.delegate didLoadAdForAdView: self.parentAdapter.adViewContainer];
    [self.delegate didDisplayAdViewAd];
}

- (void)tappxBannerViewControllerDidFail:(TappxBannerViewController *)viewController withError:(TappxErrorAd *)error
{
    MAAdapterError *adapterError = [ALTappxMediationAdapter toMaxError: error];
    
    [self.parentAdapter log: @"AdView ad failed to load with error: %@", adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)tappxBannerViewControllerDidPress:(TappxBannerViewController *)viewController
{
    [self.parentAdapter log: @"AdView ad clicked"];
    [self.delegate didClickAdViewAd];
}

- (void)tappxBannerViewControllerDidClose:(TappxBannerViewController *)viewController
{
    [self.parentAdapter log: @"AdView ad closed"];
}

@end

