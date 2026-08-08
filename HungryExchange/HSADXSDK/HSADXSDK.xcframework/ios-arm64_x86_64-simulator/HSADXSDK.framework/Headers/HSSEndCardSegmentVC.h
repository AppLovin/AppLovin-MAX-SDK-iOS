//
//  HSSEndCardSegmentVC.h
//  HSADXSDK
//
//  Created by 张松
//

#import "HSSSegmentVC.h"

NS_ASSUME_NONNULL_BEGIN

/// EndCard 段专属 VC。
///
/// 仅承担"段内 UI 装配 + UIKit 生命周期 + 响应链事件 forward"职责：
///   - segmentDidLoadAssemble：装配 HSSEndCardMedia + styleKey 整卡组件（or close/adArea） + 点击拦截层 + 创建 eventHandler
///   - viewDidAppear：通知 Media 开始展示
///   - hss_xxx：基类自动 forward 给 HSSEndCardSegmentEventHandlerImpl
///
/// 业务逻辑（companion 优先 ActionRouter / EndCard 点击埋点 trackVastEndCardClick）
/// 全部位于 HSSEndCardSegmentEventHandlerImpl 内。
@interface HSSEndCardSegmentVC : HSSSegmentVC

@end

NS_ASSUME_NONNULL_END
