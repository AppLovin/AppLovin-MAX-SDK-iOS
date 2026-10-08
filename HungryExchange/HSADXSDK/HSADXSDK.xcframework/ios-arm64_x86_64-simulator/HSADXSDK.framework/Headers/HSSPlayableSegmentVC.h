//
//  HSSPlayableSegmentVC.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSSegmentVC.h"
#import "HSSSegmentEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// 试玩段专属 VC。
///
/// 仅承担"段内 UI 装配 + UIKit 生命周期 + 响应链事件 forward"职责：
///   - segmentDidLoadAssemble：装配 HSSWebViewMedia + close/audio/overlay 组件 + 创建 eventHandler
///   - viewDidAppear：通知 Media 开始展示
///   - hss_xxx：forward 给 HSSPlayableSegmentEventHandlerImpl
///
/// 业务逻辑（Timer 持有 + Gateway TimerHolder + 前后台 suspend/resume + 点击分发）
/// 全部位于 HSSPlayableSegmentEventHandlerImpl 内。
@interface HSSPlayableSegmentVC : HSSSegmentVC

/// 类型安全的 eventHandler 访问器
@property (nonatomic, readonly, nullable) id<HSSPlayableSegmentEventHandler> playableEventHandler;

@end

NS_ASSUME_NONNULL_END
