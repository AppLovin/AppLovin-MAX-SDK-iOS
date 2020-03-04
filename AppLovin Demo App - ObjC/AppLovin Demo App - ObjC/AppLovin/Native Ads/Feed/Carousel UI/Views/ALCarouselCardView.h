//
//  ALCarouselCardView.h
//  sdk
//
//  Created by Thomas So on 4/20/15.
//
//

#import <UIKit/UIKit.h>

#import "ALCarouselMediaView.h"
#import "ALCarouselViewModel.h"
#import "ALCarouselRenderingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class ALCarouselView;

/**
 *  This view is used for paging of the carousel.
 */
@interface ALCarouselCardView : UIView<ALCarouselRenderingProtocol>

/**
 *  The view containing the ad video or image.
 */
@property (strong, nonatomic) ALCarouselMediaView *mediaView;

/**
 *  Initializes a newly allocated card view object with the specified sdk
 */
- (instancetype) initWithSdk:(ALSdk *)sdk;

/**
 *  Redirects to the CTA for the given ad.
 *
 *  @param ad The ad with the CTA URL to redirect to.
 */
- (void)handleClickForAd:(ALNativeAd *)ad;

/**
 Call this method when your view is displayed to the user.
 Will track an impression.
 */
- (void)trackImpression;

@property (strong, nonatomic, nullable)  UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic, nullable)  UIView *activityIndicatorOverlay;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
