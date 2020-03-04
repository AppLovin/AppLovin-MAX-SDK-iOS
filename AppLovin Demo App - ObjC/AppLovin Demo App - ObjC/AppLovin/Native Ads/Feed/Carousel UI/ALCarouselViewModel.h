//
//  ALCarouselModel.h
//  sdk
//
//  Created by Matt Szaro on 4/20/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALNativeAd;
@class ALCarouselCardState;
@class ALSdk;

NS_ASSUME_NONNULL_BEGIN

@interface ALCarouselViewModel : NSObject

@property (strong, nonatomic, readonly) NSArray<ALNativeAd *> *nativeAds;
@property (assign, nonatomic, readonly) NSUInteger nativeAdsCount;

- (instancetype)initWithNativeAds:(NSArray<ALNativeAd *> *)ads;
- (nullable ALCarouselCardState *)cardStateForNativeAd:(ALNativeAd *)ad;
- (nullable ALCarouselCardState *)cardStateAtNativeAdIndex:(NSUInteger)index;
- (nullable ALNativeAd *)nativeAdAtIndex:(NSUInteger)index;

- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
