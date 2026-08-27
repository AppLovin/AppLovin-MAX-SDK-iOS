//
//  HSSSegmentEventHandlers.h
//  HSADXSDK
//
//  Created by 张松
//
//  3 个段事件处理器实现类（业务代码集中地）。
//  每段一个实现类，均通过初始化时注入 segment / vc / context 三件依赖。
//
//  注：图片型 EndCard 段（HSSEndCardImageSegment）与文字型 EndCard 段（HSSEndCardSegment）
//      事件处理完全一致，共用 HSSEndCardSegmentEventHandlerImpl（基类签名兜住子类实例）。
//      段类层面已通过类型系统区分服务端 type=end_card / end_card_image 两种语义。
//

#import <Foundation/Foundation.h>
#import "HSSSegmentEventHandler.h"

@class HSSVideoSegment;
@class HSSPlayableSegment;
@class HSSEndCardSegment;
@class HSSBannerSegment;
@class HSSVideoSegmentVC;
@class HSSPlayableSegmentVC;
@class HSSEndCardSegmentVC;
@class HSSBannerSegmentVC;
@protocol HSSSegmentVCContext;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 视频段事件处理器

@interface HSSVideoSegmentEventHandlerImpl : NSObject <HSSVideoSegmentEventHandler>

- (instancetype)initWithSegment:(HSSVideoSegment *)segment
                       segmentVC:(HSSVideoSegmentVC *)vc
                         context:(id<HSSSegmentVCContext>)context;

@end

#pragma mark - 试玩段事件处理器

@interface HSSPlayableSegmentEventHandlerImpl : NSObject <HSSPlayableSegmentEventHandler>

- (instancetype)initWithSegment:(HSSPlayableSegment *)segment
                       segmentVC:(HSSPlayableSegmentVC *)vc
                         context:(id<HSSSegmentVCContext>)context;

@end

#pragma mark - EndCard 段事件处理器（仅根协议）

/// 文字 / 大图 EndCard 共用：业务侧（埋点 / 点击分发 / VAST 上报）行为一致，差异仅在 UI 装配
@interface HSSEndCardSegmentEventHandlerImpl : NSObject <HSSSegmentEventHandler>

- (instancetype)initWithSegment:(HSSEndCardSegment *)segment
                       segmentVC:(HSSEndCardSegmentVC *)vc
                         context:(id<HSSSegmentVCContext>)context;

@end

#pragma mark - Banner 段事件处理器

/// 行为对齐 1.0 HSSInterstitialBannerVC 内的业务副作用：
///   - 点击 → ActionRouter + isAdClick=YES + lastClickTime
///   - btf_auto_close：点击过 + 回前台 + 间隔超阈值 → flow.handleClose(animated:NO)
///   - dwell：回前台由 HSSModularAdVC 统一上报；InnerWebVC 关闭由本 Handler 补报
///   - 白屏检测：banner 段 reveal 后启动（与 1.0 didMoveToWindow.window!=nil 时机等价）
///   - 前后台切换：OMID pause/resume + btf_auto_close
/// SKAd / adx_sdk_show_duration 由 HSSModularAdVC 广告级统一处理（与视频/试玩一致）
@interface HSSBannerSegmentEventHandlerImpl : NSObject <HSSBannerSegmentEventHandler>

- (instancetype)initWithSegment:(HSSBannerSegment *)segment
                       segmentVC:(HSSBannerSegmentVC *)vc
                         context:(id<HSSSegmentVCContext>)context;

@end

NS_ASSUME_NONNULL_END
