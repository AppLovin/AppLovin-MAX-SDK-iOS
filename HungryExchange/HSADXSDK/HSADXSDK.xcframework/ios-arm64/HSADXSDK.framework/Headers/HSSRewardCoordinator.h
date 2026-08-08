//
//  HSSRewardCoordinator.h
//  HSADXSDK
//
//  Created by 张松
//
//  独立的激励（reward）状态机。
//
//  定位：
//    2.0 架构里"激励是否达成"的唯一决策器。上游输入的是"UI / 播放事实"（不带业务语义），
//    由决策器根据规则判断是否满足激励条件；一旦满足即不可逆，`onRewardReached` 保证只触发一次。
//
//  为什么独立成类：
//    - 段流转（FlowCoordinator）和激励达成是两个正交维度的状态机，不应耦合
//    - 组件只应发 UI 事实，不应知道"激励"这个业务语义（SRP）
//    - 未来激励规则变化（如"必须看完视频且点击过 EndCard"等复合条件）
//      只在本类内部扩展，不影响上游事件源
//
//  线程模型：
//    所有 `reportXxx` 方法必须在**主线程**调用（与 UIKit 响应链、NSTimer 一致）。
//    `hasReached` 属性同上。
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSRewardCoordinator : NSObject

- (instancetype)initWithCreative:(HSSCreativeItemModel *)creative;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - UI / 播放事实上报（不带业务语义）

/// 倒计时结束（视频段 / 试玩段 close.count_down 走完）
/// 上游可能源：
///   - 组件响应链事件 hss_countdownFinished（视频段 / 试玩段 EH.handleCountdownFinished 转发）
///   - 视频自然播完比 count_down 早时（HSSVideoSegmentEventHandlerImpl.handleMediaFinished 兜底触发）
/// 这是 2.0 架构下**激励的唯一权威源**（按 count_down 看够规定时长）。
/// EC 段不参与激励触发（产品规则：仅视频段 / 试玩段倒计时算激励）。
- (void)reportCountdownFinished;

#pragma mark - 业务语义出口（保证单次）

/// 激励达成回调：Pending → Reached 不可逆，最多触发一次
@property (nonatomic, copy, nullable) void(^onRewardReached)(void);

/// 查询是否已达成（供 Ad 层按需查询状态）
@property (nonatomic, assign, readonly) BOOL hasReached;

@end

NS_ASSUME_NONNULL_END
