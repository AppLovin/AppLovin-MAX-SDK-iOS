//
//  ALCarouselReplayOverlayView.h
//  sdk
//
//  Created by Thomas So on 4/22/15.
//
//

@import UIKit;
#import "ALCarouselMediaView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This view provides a few buttons to allow the user to replay or click through an ad.
 */
@interface ALCarouselReplayOverlayView : UIView

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIButton *replayButton;
@property (strong, nonatomic) UIButton *replayIconButton;
@property (strong, nonatomic) UIButton *learnMoreButton;
@property (strong, nonatomic) UIButton *learnMoreIconButton;

- (instancetype)initWithParentView:(ALCarouselMediaView *)parentView;

@end

NS_ASSUME_NONNULL_END
