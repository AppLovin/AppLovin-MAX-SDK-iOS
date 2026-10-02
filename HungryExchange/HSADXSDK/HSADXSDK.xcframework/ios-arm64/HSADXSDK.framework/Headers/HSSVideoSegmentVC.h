//
//  HSSVideoSegmentVC.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSSegmentVC.h"
#import "HSSSegmentEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// 视频段专属 VC。
///
/// 仅承担"段内 UI 装配 + UIKit 生命周期 + 响应链事件 forward"职责：
///   - segmentDidLoadAssemble：装配 HSSVideoMedia + close/audio/overlay 组件 + 点击拦截层 + 创建 eventHandler
///   - viewDidAppear：触发 OMID 新段 session + 开始播放（UIKit 时序点）
///   - hss_xxx：forward 给 HSSVideoSegmentEventHandlerImpl（业务集中地）
///
/// 业务逻辑（VAST 埋点 / OMID / count_down 激励 / auto_next / AutoStore / WebviewOverlay 等）
/// 全部位于 HSSVideoSegmentEventHandlerImpl 内。
@interface HSSVideoSegmentVC : HSSSegmentVC

/// 类型安全的 eventHandler 访问器（cast 自 self.eventHandler）。
/// 仅供子类内部 / forward 链路使用，外部勿调。
@property (nonatomic, readonly, nullable) id<HSSVideoSegmentEventHandler> videoEventHandler;

@end

NS_ASSUME_NONNULL_END
