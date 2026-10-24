//
//  HSSVideoSkipTemplateHandler.h
//  HSADXSDK
//  Created by biyingquan on 2025/04/15.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>
#import "HSSAdSkipCountDownView.h"
#import "HSSAdTipCircularCountDownView.h"
#import "HSSSectorCountDownView.h"

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

@protocol HSSVideoSkipTemplatePerforming <NSObject>
- (void)performInterstitialVideoSkipProgressBar:(NSInteger)skipTime;
- (void)performInterstitialVideoSkipCircularBottom:(NSInteger)skipTime;
- (void)performInterstitialVideoSkipCircularTopRight:(NSInteger)skipTime;
- (void)performSkipCountDown:(NSInteger)seconds enableBorder:(BOOL)border adFormat:(HSSAdFormatType)format adSkipCountDownType:(HSSAdSkipCountDownType)adSkipCountDownType;
- (void)performEllipseCountDown:(NSInteger)seconds adFormat:(HSSAdFormatType)format;
- (void)performTipCircularCountDown:(NSInteger)seconds adFormat:(HSSAdFormatType)format frame:(CGRect)frame displayType:(HSSAdTipCircularCountDownDisplayType)displayType;
- (void)performSectorCountDown:(NSInteger)seconds adFormat:(HSSAdFormatType)adFormat frame:(CGRect)frame countDownType:(HSSSectorCountDownType)countDownType;
@end

@interface HSSVideoSkipTemplateHandler : NSObject

+ (void)applyInstlTemplate:(NSInteger)tmpl skipTime:(NSInteger)skipTime performer:(id<HSSVideoSkipTemplatePerforming>)performer;
+ (void)applyRewardTemplate:(NSInteger)tmpl rewardTime:(NSInteger)rewardTime performer:(id<HSSVideoSkipTemplatePerforming>)performer;

/// 插屏视频自然播放结束时，是否应按「关闭广告」处理（如 instl_video_tmpl == 10 的 VAST 场景）。
+ (BOOL)shouldCloseInterstitialAdWhenVideoFinishesForItemModel:(nullable HSSCreativeItemModel *)itemModel
                                                      adFormat:(HSSAdFormatType)adFormat
                                                 isDoubleVideo:(BOOL)isDoubleVideo;

@end

NS_ASSUME_NONNULL_END
