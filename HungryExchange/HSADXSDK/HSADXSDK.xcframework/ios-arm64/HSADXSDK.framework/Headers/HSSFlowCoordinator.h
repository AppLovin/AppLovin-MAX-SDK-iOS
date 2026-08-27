//
//  HSSFlowCoordinator.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>

@class HSSTmplInfo;
@class HSSTmplSegment;
@class HSSRewardCoordinator;
@protocol HSSSegmentRouterHost;

NS_ASSUME_NONNULL_BEGIN

/// 模版 2.0 架构下的"段流转状态机"。
///
/// 职责：
///   - segments 之间的切换（moveToNext / moveToIndex）
///   - 基于 next_link.autoNext/strategy/value 的自动切段判断
///   - Close 行为分流（按 close_next 决定切段 or dismiss）
///   - close.count_down 倒计时结束时，上报"事实"给 HSSRewardCoordinator（视频段 / 试玩段）
///   - 切段 / dismiss 动作通过 host 协议转交 UIKit 容器执行
///
/// 不负责：
///   - "是否给奖励" 的业务决策（交给 HSSRewardCoordinator）
///   - UI 渲染 / 段内业务 / 埋点（各段 VC 自管）
@interface HSSFlowCoordinator : NSObject

/// 当前段
@property (nonatomic, strong, readonly, nullable) HSSTmplSegment *currentSegment;

/// 当前段索引
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/// 总段数
@property (nonatomic, assign, readonly) NSInteger totalSegments;

/// 是否已经是最后一段
@property (nonatomic, assign, readonly) BOOL isLastSegment;

#pragma mark - 路由宿主（所有段切换 / dismiss 都走 host 协议）

/// 段路由宿主（通常为 HSSModularAdVC）
/// moveToIndex 调 host.routerRequestsTransitionToSegmentAtIndex: 执行 UIKit Containment 切换；
/// dismiss 走 host.routerRequestsDismissWithParams:。
@property (nonatomic, weak, nullable) id<HSSSegmentRouterHost> host;

/// 激励决策器（由 VC 注入）。Flow 只上报"视频进度到达"事实，决策权归决策器。
@property (nonatomic, weak, nullable) HSSRewardCoordinator *rewardCoordinator;

#pragma mark - 生命周期

- (instancetype)initWithTmplInfo:(HSSTmplInfo *)tmplInfo;

/// 启动，进入第一段
- (void)start;

#pragma mark - 业务事件入口（每个语义事件独立方法，类型安全）

/// 当前段媒体播放完成（或播放失败降级），进入下一段；若已是最后一段则 dismiss
- (void)handleMediaFinished;

/// 用户点击"跳过"，进入下一段；若已是最后一段则 dismiss
- (void)handleSkipTapped;

/// 用户点击"关闭"：按当前段 next_link.close_next 决定进下一段 or dismiss
/// @param params 透传给 onDismiss 的附加信息（如 close_position）
- (void)handleCloseTappedWithParams:(nullable NSDictionary *)params;

/// 段不可用（material 缺失 / isValidMaterial 为 NO）→ 跳过当前段，进入下一段
/// 语义与 handleMediaFinished / handleSkipTapped 区分：后者是"用户/媒体自然结束"，此方法是"素材无法渲染强制跳过"
/// 由 Host 在 routerRequestsTransitionToSegmentAtIndex: 预检失败时调用，保证不会创建无效 SegmentVC
/// @param index  要跳过的段索引（语义上等于 currentIndex+1 的起点，但保留参数便于未来扩展）
/// @param reason 跳过原因（日志 / 后续埋点用，如 @"material_missing" / @"material_invalid"）
- (void)segmentUnavailableAtIndex:(NSInteger)index reason:(NSString *)reason;

@end

NS_ASSUME_NONNULL_END
