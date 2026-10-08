//
//  HSSALVideoPopupView.h
//  HSADXSDK
//
//  Created by admin on 2025/5/20.
//

#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@class HSSPlayableModel;
@class HSSPlayUniTmplMaterialModel;
@class HSSAdxUniTmplModel;

@interface HSSALVideoPopupView : HSSBaseView
/// 已展示次数
@property (nonatomic, assign, readonly) NSInteger shownCount;

@property (nonatomic, assign, readonly) BOOL isShow;

- (instancetype)initWithModel:(HSSPlayableModel *)model;

- (instancetype)initWithUniTmplMaterialModel:(HSSPlayUniTmplMaterialModel *)uniTmplMaterialModel;

- (instancetype)initWithAdxUniTmplModel:(HSSAdxUniTmplModel *)adxUniTmplModel;

- (void)showInView:(UIView *)superView atPoint:(CGPoint)point;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
