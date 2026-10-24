//
//  HSSCloseButton.h
//  HSADXSDK
//
//  Created by admin on 2024/12/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HSSTimeButtonType) {
    HSSTimeButtonTypeSkip = 1,   // 跳过
    HSSTimeButtonTypeClose = 2   // 关闭
};


@interface HSSTimeButton : UIButton

/**
 @param interval  时间间隔
 @param  complete  时间结束回调
 */
-(void)startInterval:(NSTimeInterval)interval complete:(nullable void (^)(void))complete;

-(void)stop;

- (CGRect)hss_expandedHitBounds;

// 设置点击区域扩大的边距
@property (nonatomic, assign) UIEdgeInsets enlargedEdge;

@property (nonatomic, assign) HSSTimeButtonType timeButtonType;

@end

NS_ASSUME_NONNULL_END
