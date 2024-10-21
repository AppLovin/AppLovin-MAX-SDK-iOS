//
//  ALGoogleAdViewDelegate.m
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleAdViewDelegate.h"

@interface ALGoogleAdViewDelegate ()
@property (nonatomic, weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, weak) MAAdFormat *adFormat;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
@end

@implementation ALGoogleAdViewDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                             adFormat:(MAAdFormat *)adFormat
                            andNotify:(id<MAAdViewAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.adFormat = adFormat;
        self.delegate = delegate;
    }
    return self;
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad loaded: %@", self.adFormat.label, bannerView.adUnitID];
    
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithCapacity: 3];
    
    NSString *responseId = bannerView.responseInfo.responseIdentifier;
    if ( [responseId al_isValidString] )
    {
        extraInfo[@"creative_id"] = responseId;
    }
    
    CGSize adSize = bannerView.adSize.size;
    if ( !CGSizeEqualToSize(CGSizeZero, adSize) )
    {
        extraInfo[@"ad_width"] = @(adSize.width);
        extraInfo[@"ad_height"] = @(adSize.height);
    }
    
    [self.delegate didLoadAdForAdView: bannerView withExtraInfo: extraInfo];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    MAAdapterError *adapterError = [ALGoogleMediationAdapter toMaxError: error];
    [self.parentAdapter log: @"%@ ad (%@) failed to load with error: %@", self.adFormat.label, bannerView.adUnitID, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad shown: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didDisplayAdViewAd];
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad clicked: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didClickAdViewAd];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad will present: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didExpandAdViewAd];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self.parentAdapter log: @"%@ ad collapsed: %@", self.adFormat.label, bannerView.adUnitID];
    [self.delegate didCollapseAdViewAd];
}

@end
