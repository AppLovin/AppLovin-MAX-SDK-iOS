//
//  HSSVideoPlayerProtocol.h
//  HSADXSDK
//
//  Created by admin on 2024/12/9.
//

#import <Foundation/Foundation.h>
#import "HSSPlayUniTmplModel.h"

@class HSSPlayer;
NS_ASSUME_NONNULL_BEGIN

@protocol HSSVideoPlayerProtocol <NSObject>
/**
 视频开始播放
 */
-(void)videoStartPlay:(nonnull HSSPlayer *)player;

/**
 视频播放完成
 */
-(void)videoFinishPlay:(nonnull HSSPlayer *)player;

- (void)uniTmplVideoFinishPlay:(nonnull HSSPlayer *)player;

- (void)adxUniTmplFinishedPlay:(nonnull HSSPlayer *)player;

- (void)uniTmplTopViewHideMuteBtnWithModel:(HSSPlayUniTmplMaterialModel *)materialModel;

- (void)uniTmplFinishPlayForFirstSection:(nonnull HSSPlayer *)player;

//- (void)uniTmplVideoShowMoreView:(NSString *)iconIvUrl moreText:(NSString *)moreText;

- (void)uniTmplVideoShowWithModel:(HSSPlayUniTmplMaterialModel *)materialModel;

@optional
/**
 视频尺寸已就绪（可以进行 PageView 上报）
 */
- (void)videoSizeReady:(nonnull HSSPlayer *)player videoSize:(CGSize)videoSize;

/**
 首帧真正上屏（readyForDisplay=YES）—— real_play 事件源
 */
- (void)videoFirstFrameDisplayed:(nonnull HSSPlayer *)player;

/**
 播放真正推进过阈值时间点 —— time_reached 事件源（区分有音无画 vs 起播卡死）
 */
- (void)videoPlaybackReached:(nonnull HSSPlayer *)player;

@end

NS_ASSUME_NONNULL_END
