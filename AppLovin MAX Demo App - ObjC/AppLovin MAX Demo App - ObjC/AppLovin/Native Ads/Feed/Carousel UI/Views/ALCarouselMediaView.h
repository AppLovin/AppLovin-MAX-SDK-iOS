//
//  ALCarouselMediaView.h
//  sdk
//
//  Created by Thomas So on 4/20/15.
//
//

#import <UIKit/UIKit.h>

#import "ALCarouselViewModel.h"
#import "ALCarouselRenderingProtocol.h"

@class ALCarouselCardView;

NS_ASSUME_NONNULL_BEGIN

/**
 * This view is used to store the ad's media.
 */
@interface ALCarouselMediaView : UIView<ALCarouselRenderingProtocol>

/**
 * Saves the current video's states and clears it. This is for when moving a slot out of the middle card.
 */
- (void)setInactive;

/**
 * Initializes a newly allocated media view object with the specified sdk and parent card view.
 */
- (instancetype)initWithSdk:(ALSdk *)sdk parentView:(ALCarouselCardView *)parentView;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
