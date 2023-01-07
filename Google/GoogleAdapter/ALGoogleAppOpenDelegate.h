//
//  ALGoogleAppOpenDelegate.h
//  GoogleAdapter
//
//  Created by Vedant Mehta on 8/11/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ALGoogleMediationAdapter.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: Remove when SDK with App Open APIs is released
@protocol MAAppOpenAdapterDelegateTemp <MAAdapterDelegate>
- (void)didLoadAppOpenAd;
- (void)didLoadAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToLoadAppOpenAdWithError:(MAAdapterError *)adapterError;
- (void)didDisplayAppOpenAd;
- (void)didDisplayAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didClickAppOpenAd;
- (void)didClickAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didHideAppOpenAd;
- (void)didHideAppOpenAdWithExtraInfo:(nullable NSDictionary<NSString *, id> *)extraInfo;
- (void)didFailToDisplayAppOpenAdWithError:(MAAdapterError *)adapterError;
@end

@interface ALGoogleAppOpenDelegate : NSObject <GADFullScreenContentDelegate>

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate;

@end

NS_ASSUME_NONNULL_END
