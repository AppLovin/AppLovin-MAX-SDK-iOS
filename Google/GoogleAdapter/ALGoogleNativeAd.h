//
//  ALGoogleNativeAd.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Thomas So on 7/21/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALGoogleMediationAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleNativeAd : MANativeAd

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                   gadNativeAdViewTag:(NSInteger)gadNativeAdViewTag
                         builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
