//
//  ALGoogleNativeAd.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleNativeAd.h"

#define TITLE_LABEL_TAG          1
#define MEDIA_VIEW_CONTAINER_TAG 2
#define ICON_VIEW_TAG            3
#define BODY_VIEW_TAG            4
#define CALL_TO_ACTION_VIEW_TAG  5
#define ADVERTISER_VIEW_TAG      8

@interface ALGoogleMediationAdapter ()
@property (nonatomic, strong) GADNativeAd *nativeAd;
@property (nonatomic, strong) GADNativeAdView *nativeAdView;
@end

@interface ALGoogleNativeAd ()
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
    [self prepareForInteractionClickableViews: @[] withContainer: maxNativeAdView];
}

- (BOOL)prepareForInteractionClickableViews:(NSArray<UIView *> *)clickableViews withContainer:(UIView *)container
{
    GADNativeAd *nativeAd = self.parentAdapter.nativeAd;
    if ( !nativeAd )
    {
        [self.parentAdapter e: @"Failed to register native ad views: native ad is nil."];
        return NO;
    }
    
    // Check if the publisher included Google's `GADNativeAdView`. If we can use an integrated view, Google
    // won't need to overlay the view on top of the pub view, causing unrelated buttons to be unclickable
    GADNativeAdView *gadNativeAdView = [container viewWithTag: self.gadNativeAdViewTag];
    if ( ![gadNativeAdView isKindOfClass: [GADNativeAdView class]] )
    {
        gadNativeAdView = [[GADNativeAdView alloc] init];
        
        // Save the manually created view to be removed later
        self.parentAdapter.nativeAdView = gadNativeAdView;
        
        // NOTE: iOS needs order to be maxNativeAdView -> gadNativeAdView in order for assets to be sized correctly
        [container addSubview: gadNativeAdView];
        
        // Pin view in order to make it clickable - this makes views not registered with the native ad view unclickable
        [gadNativeAdView al_pinToSuperview];
    }
    
    // Native integrations
    if ( [container isKindOfClass: [MANativeAdView class]] )
    {
        MANativeAdView *maxNativeAdView = (MANativeAdView *) container;
        gadNativeAdView.headlineView = maxNativeAdView.titleLabel;
        gadNativeAdView.advertiserView = maxNativeAdView.advertiserLabel;
        gadNativeAdView.bodyView = maxNativeAdView.bodyLabel;
        gadNativeAdView.iconView = maxNativeAdView.iconImageView;
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
    }
    // Plugins
    else
    {
        for ( UIView *clickableView in clickableViews )
        {
            if ( clickableView.tag == TITLE_LABEL_TAG )
            {
                gadNativeAdView.headlineView = clickableView;
            }
            else if ( clickableView.tag == ICON_VIEW_TAG )
            {
                gadNativeAdView.iconView = clickableView;
            }
            else if ( clickableView.tag == MEDIA_VIEW_CONTAINER_TAG )
            {
                // `self.mediaView` is created when ad is loaded
                if ( [self.mediaView isKindOfClass: [GADMediaView class]] )
                {
                    gadNativeAdView.mediaView = (GADMediaView *) self.mediaView;
                }
                else if ( [self.mediaView isKindOfClass: [UIImageView class]] )
                {
                    gadNativeAdView.imageView = self.mediaView;
                }
            }
            else if ( clickableView.tag == BODY_VIEW_TAG )
            {
                gadNativeAdView.bodyView = clickableView;
            }
            else if ( clickableView.tag == CALL_TO_ACTION_VIEW_TAG )
            {
                gadNativeAdView.callToActionView = clickableView;
            }
            else if ( clickableView.tag == ADVERTISER_VIEW_TAG )
            {
                gadNativeAdView.advertiserView = clickableView;
            }
        }
    }
    
    gadNativeAdView.nativeAd = self.parentAdapter.nativeAd;
    
    return YES;
}

@end
