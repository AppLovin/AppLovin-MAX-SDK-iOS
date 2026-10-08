//
//  HSSADXBottomProgressView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/1/7.
//

#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/// 贴底 2pt 细进度条；老架构 HSSVideoPlayerVC 全屏使用；模板 2.0 通过 `HSSAdComponentProtocol` 挂载，key：`video_bottom_progress_key`
@interface HSSADXBottomProgressView : HSSBaseView <HSSAdComponentProtocol>

/// 进度条已完成部分的颜色
@property (nonatomic, copy) NSString *progressTintColor;
/// 进度条未完成部分的颜色
@property (nonatomic, copy) NSString *trackTintColor;
/// 是否需要显示进度条
@property (nonatomic, assign) BOOL is_show;

- (void)updateProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
