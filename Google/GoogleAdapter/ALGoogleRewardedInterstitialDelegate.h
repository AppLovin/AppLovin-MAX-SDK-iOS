//
//  ALGoogleRewardedInterstitialDelegate.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ALGoogleMediationAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleRewardedInterstitialDelegate : NSObject<GADFullScreenContentDelegate>

@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MARewardedInterstitialAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
