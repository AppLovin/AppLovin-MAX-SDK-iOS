//
//  ALCarouselView.h
//
//  Created by Thomas So on 3/30/15.
//  Copyright (c) 2015, AppLovin Corporation. All rights reserved.
//

@import AppLovinSDK;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class is used to display native ads to the user.
 */
@interface ALCarouselView : UIView

/**
 *  An object conforming to the ALNativeAdGroupLoadDelegate protocol, which, if set, will be notified of ad load events.
 */
@property (weak, nonatomic, nullable) id<ALNativeAdLoadDelegate> loadDelegate;

/**
 *  The current native ad(s) being displayed.
 */
@property (strong, nonatomic, readonly) NSArray<ALNativeAd *> *nativeAds;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame sdk:(ALSdk *)sdk;
- (instancetype)initWithFrame:(CGRect)frame sdk:(ALSdk *)sdk nativeAds:(NSArray<ALNativeAd *> *)nativeAds;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
