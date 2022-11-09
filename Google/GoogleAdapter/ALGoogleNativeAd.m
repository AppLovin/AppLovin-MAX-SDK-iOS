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
@property (nonatomic,   weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, assign) NSInteger gadNativeAdViewTag;
@end

@implementation ALGoogleNativeAd

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                   gadNativeAdViewTag:(NSInteger)gadNativeAdViewTag
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock
{
    self = [super initWithFormat: MAAdFormat.native builderBlock: builderBlock];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.gadNativeAdViewTag = gadNativeAdViewTag;
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
    
    // Check if the publisher included Google's `GADNativeAdView`. If we can use an integrated view, Google
    // won't need to overlay the view on top of the pub view, causing unrelated buttons to be unclickable
    GADNativeAdView *gadNativeAdView = [maxNativeAdView viewWithTag: self.gadNativeAdViewTag];
    if ( ![gadNativeAdView isKindOfClass: [GADNativeAdView class]] )
    {
        gadNativeAdView = [[GADNativeAdView alloc] init];
        
        // Save the manually created view to be removed later
        self.parentAdapter.nativeAdView = gadNativeAdView;
        
        // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
        [maxNativeAdView addSubview: gadNativeAdView];
        
        // Pin view in order to make it clickable - this makes views not registered with the native ad view unclickable
        [gadNativeAdView al_pinToSuperview];
    }
    
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
}

@end
