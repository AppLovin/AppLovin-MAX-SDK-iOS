//
//  ALGoogleInterstitialDelegate.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ALGoogleMediationAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleInterstitialDelegate : NSObject <GADFullScreenContentDelegate>

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
