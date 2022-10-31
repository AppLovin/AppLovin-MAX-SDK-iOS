//
//  ALGoogleNativeAdDelegate.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleNativeAdDelegate.h"
#import "ALGoogleNativeAd.h"

@interface ALGoogleMediationAdapter()
@property (nonatomic, strong) GADNativeAd *nativeAd;
@end

@interface ALGoogleNativeAdDelegate()
@property (nonatomic,   weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, strong) NSDictionary<NSString *, id> *serverParameters;
@property (nonatomic, strong) id<MANativeAdAdapterDelegate> delegate;
@property (nonatomic, assign) NSInteger gadNativeAdViewTag;
@end

@implementation ALGoogleNativeAdDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.serverParameters = parameters.serverParameters;
        self.delegate = delegate;
        
        id gadNativeAdViewTagObj = parameters.localExtraParameters[@"google_native_ad_view_tag"];
        if ( [gadNativeAdViewTagObj isKindOfClass: [NSNumber class]] )
        {
            self.gadNativeAdViewTag = ((NSNumber *) gadNativeAdViewTagObj).integerValue;
        }
        else
        {
            self.gadNativeAdViewTag = -1;
        }
    }
    return self;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad loaded: %@", adLoader.adUnitID];
    
    self.parentAdapter.nativeAd = nativeAd;
    
    NSString *templateName = [self.serverParameters al_stringForKey: @"template" defaultValue: @""];
    BOOL isTemplateAd = [templateName al_isValidString];
    if ( isTemplateAd && ![nativeAd.headline al_isValidString] )
    {
        [self.parentAdapter e: @"Native ad (%@) does not have required assets.", nativeAd];
        [self.delegate didFailToLoadNativeAdWithError: [MAAdapterError errorWithCode: -5400 errorString: @"Missing Native Ad Assets"]];
        
        return;
    }
    
    UIView *mediaView;
    GADMediaContent *mediaContent = nativeAd.mediaContent;
    MANativeAdImage *mainImage = nil;
    CGFloat mediaContentAspectRatio = 0.0f;
    
    if ( mediaContent )
    {
        GADMediaView *gadMediaView = [[GADMediaView alloc] init];
        [gadMediaView setMediaContent: mediaContent];
        mediaView = gadMediaView;
        mainImage = [[MANativeAdImage alloc] initWithImage: mediaContent.mainImage];
        
        mediaContentAspectRatio = mediaContent.aspectRatio;
    }
    else if ( nativeAd.images.count > 0 )
    {
        GADNativeAdImage *mediaImage = nativeAd.images[0];
        UIImageView *mediaImageView = [[UIImageView alloc] initWithImage: mediaImage.image];
        mediaView = mediaImageView;
        mainImage = [[MANativeAdImage alloc] initWithImage: mediaImage.image];
        
        mediaContentAspectRatio = mediaImage.image.size.width / mediaImage.image.size.height;
    }
    
    nativeAd.delegate = self;
    
    // Fetching the top view controller needs to be on the main queue
    dispatchOnMainQueue(^{
        nativeAd.rootViewController = [ALUtils topViewControllerFromKeyWindow];
    });
    
    MANativeAd *maxNativeAd = [[ALGoogleNativeAd alloc] initWithParentAdapter: self.parentAdapter
                                                           gadNativeAdViewTag: self.gadNativeAdViewTag
                                                                 builderBlock:^(MANativeAdBuilder *builder) {
        
        builder.title = nativeAd.headline;
        builder.body = nativeAd.body;
        builder.callToAction = nativeAd.callToAction;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        // Introduced in 10.4.0
        if ( [builder respondsToSelector: @selector(setAdvertiser:)] )
        {
            [builder performSelector: @selector(setAdvertiser:) withObject: nativeAd.advertiser];
        }
#pragma clang diagnostic pop
        
        builder.mediaView = mediaView;
        if ( ALSdk.versionCode >= 11040299 )
        {
            [builder performSelector: @selector(setMainImage:) withObject: mainImage];
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        // Introduced in 11.4.0
        if ( [builder respondsToSelector: @selector(setMediaContentAspectRatio:)] )
        {
            [builder performSelector: @selector(setMediaContentAspectRatio:) withObject: @(mediaContentAspectRatio)];
        }
#pragma clang diagnostic pop
        
        if ( nativeAd.icon.image ) // Cached
        {
            builder.icon = [[MANativeAdImage alloc] initWithImage: nativeAd.icon.image];
        }
        else // URL may require fetching
        {
            builder.icon = [[MANativeAdImage alloc] initWithURL: nativeAd.icon.imageURL];
        }
    }];
    
    NSString *responseId = nativeAd.responseInfo.responseIdentifier;
    NSDictionary *extraInfo = [responseId al_isValidString] ? @{@"creative_id" : responseId} : nil;
    
    [self.delegate didLoadAdForNativeAd: maxNativeAd withExtraInfo: extraInfo];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"Native ad (%@) failed to load with error: %@", adLoader.adUnitID, adapterError];
    [self.delegate didFailToLoadNativeAdWithError: adapterError];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad shown"];
    [self.delegate didDisplayNativeAdWithExtraInfo: nil];
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad clicked"];
    [self.delegate didClickNativeAd];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad will present"];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd
{
    [self.parentAdapter log: @"Native ad did dismiss"];
}

@end
