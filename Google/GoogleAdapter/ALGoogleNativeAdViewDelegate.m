//
//  ALGoogleNativeAdViewDelegate.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleNativeAdViewDelegate.h"

@interface ALGoogleMediationAdapter ()
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@end

@interface ALGoogleNativeAdViewDelegate ()
@property (nonatomic, weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, weak) MAAdFormat *adFormat;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@end

@implementation ALGoogleNativeAdViewDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                     serverParameters:(NSDictionary<NSString *, id> *)serverParameters
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.adFormat = adFormat;
        self.serverParameters = serverParameters;
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad loaded: %@", self.adFormat.label, adLoader.adUnitID];
    
    if ( ![nativeAd.headline al_isValidString] )
    {
        [self.parentAdapter log: @"Native %@ ad failed to load: Google native ad is missing one or more required assets", self.adFormat.label];
        [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.missingRequiredNativeAdAssets];
        
        return;
    }
    
    GADMediaView *gadMediaView = [[GADMediaView alloc] init];
    MANativeAd *maxNativeAd = [[MANativeAd alloc] initWithFormat: self.adFormat builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
        
        if ( nativeAd.mediaContent )
        {
            [gadMediaView setMediaContent: nativeAd.mediaContent];
            builder.mediaView = gadMediaView;
        }
    }];
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    if ( [templateName containsString: @"vertical"] && ALSdk.versionCode < 6140500 )
    {
        [self.parentAdapter log: @"Vertical native banners are only supported on MAX SDK 6.14.5 and above. Default native template will be used."];
    }
    
    nativeAd.delegate = self;
    
    dispatchOnMainQueue(^{
        
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
        
        MANativeAdView *maxNativeAdView;
        maxNativeAdView = [MANativeAdView nativeAdViewFromAd: maxNativeAd withTemplate: templateName];
        
        GADNativeAdView *gadNativeAdView = [[GADNativeAdView alloc] init];
        gadNativeAdView.iconView = maxNativeAdView.iconImageView;
        gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
        gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
        gadNativeAdView.mediaView = gadMediaView;
        gadNativeAdView.callToActionView = maxNativeAdView.callToActionButton;
        gadNativeAdView.callToActionView.userInteractionEnabled = NO;
        gadNativeAdView.nativeAd = nativeAd;
        
        self.parentAdapter.nativeAdView = gadNativeAdView;
        
        // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
        [maxNativeAdView addSubview: self.parentAdapter.nativeAdView];
        
        // Pin view in order to make it clickable
        [self.parentAdapter.nativeAdView al_pinToSuperview];
        
        NSString *responseId = nativeAd.responseInfo.responseIdentifier;
        if ( [responseId al_isValidString] )
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView withExtraInfo: @{@"creative_id" : responseId}];
        }
        else
        {
            [self.delegate didLoadAdForAdView: maxNativeAdView];
        }
    });
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error;
{
    MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native %@ ad (%@) failed to load with error: %@", self.adFormat.label, adLoader.adUnitID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad shown", self.adFormat.label];
    [self.delegate didDisplayAdViewAd];
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad clicked", self.adFormat.label];
    [self.delegate didClickAdViewAd];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad will present", self.adFormat.label];
    [self.delegate didExpandAdViewAd];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native %@ ad did dismiss", self.adFormat.label];
    [self.delegate didCollapseAdViewAd];
}

@end
