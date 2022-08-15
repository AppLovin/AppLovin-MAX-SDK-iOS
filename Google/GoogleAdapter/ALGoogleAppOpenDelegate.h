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

@interface ALGoogleAppOpenDelegate: NSObject<GADFullScreenContentDelegate>

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAppOpenAdapterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
