//
//  ALGoogleNativeAd.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleNativeAd.h"

@interface ALGoogleMediationAdapter()
@property (nonatomic, strong) GADNativeAd *nativeAd;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@end

@interface ALGoogleNativeAd()
@property (nonatomic, weak) ALGoogleMediationAdapter *parentAdapter;
@end

@implementation ALGoogleNativeAd

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
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
    GADNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return;
    }
    
    GADNativeAdView *gadNativeAdView = [[GADNativeAdView alloc] init];
    gadNativeAdView.iconView = maxNativeAdView.iconImageView;
    gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
    gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
    gadNativeAdView.callToActionView = maxNativeAdView.callToActionButton;
    gadNativeAdView.callToActionView.userInteractionEnabled = NO;
    
    if ( [self.mediaView isKindOfClass: [GADMediaView class]] )
    {
        gadNativeAdView.mediaView = (GADMediaView *) self.mediaView;
    }
    else if ( [self.mediaView isKindOfClass: [UIImageView class]] )
    {
        gadNativeAdView.imageView = self.mediaView;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Introduced in 10.4.0
    if ( [maxNativeAdView respondsToSelector: @selector(advertiserLabel)] )
    {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        gadNativeAdView.advertiserView = advertiserLabel;
    }
#pragma clang diagnostic pop
    
    gadNativeAdView.nativeAd = self.parentAdapter.nativeAd;
    
    // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
    [maxNativeAdView addSubview: gadNativeAdView];
    
    // Pin view in order to make it clickable
    [gadNativeAdView al_pinToSuperview];
    
    self.parentAdapter.nativeAdView = gadNativeAdView;
}

@end
