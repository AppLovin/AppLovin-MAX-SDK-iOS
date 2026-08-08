//
//  HSSALVideoOverlayView.h
//  HSADXSDK
//
//  Created by admin on 2025/5/20.
//

#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class HSSPlayableModel;

@interface HSSALVideoOverlayView : HSSBaseView

- (void)configViewWithData:(HSSPlayableModel *)playableModel;

@end

NS_ASSUME_NONNULL_END
