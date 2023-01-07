//
//  ALGoogleNativeAdDelegate.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ALGoogleMediationAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleNativeAdDelegate : NSObject <GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate>

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                           parameters:(id<MAAdapterResponseParameters>)parameters
                            andNotify:(id<MANativeAdAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
