//
//  HSSModularPlayableGameTimer.h
//  HSADXSDK
//
//  Created by 张松
//
//  Playable 游戏运行期间的状态与节点上报。
//
//  对齐老架构（HSSInterstitialVC）：
//    - webLoadTime：JS 发 gameStart 时记录（计算 skip duration 的基准）
//    - playGameTimer：每秒 +1，在 15/30/45/60 秒节点通过 progressHandler 上抛 "1"/"2"/"3"/"4"
//    - gameEnd / skip：stopAndReportSkip:endReason: 算 duration = now - webLoadTime，经 skipHandler 上抛
//
//  2.0 下：Gateway（或 Coordinator）持有 timer；打点通过 block 回调给 tracker
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSModularPlayableGameTimer : NSObject

/// 每个关键节点（15/30/45/60s）触发；progress 为 "1" / "2" / "3" / "4"
@property (nonatomic, copy, nullable) void (^progressHandler)(NSString *progress);

/// skip / gameEnd 发生时触发；duration = now - webLoadTime（单位：秒）
@property (nonatomic, copy, nullable) void (^skipHandler)(NSInteger duration, NSString *endReason);

/// 启动：记录 webLoadTime + 启动每秒计时
- (void)start;

/// 停止并上抛 skip（幂等：重复调用无副作用）
- (void)stopAndReportSkip:(NSString *)endReason;

/// App 进入后台 → 暂停 tick 累积（对齐老 HSSInterstitialVC.appDidEnterBackground 对 playGameTimer.setFireDate:）
- (void)suspend;

/// App 回到前台 → 恢复 tick 累积
- (void)resume;

/// JS 发 gameStart 时调 start；VC 的 skip 按钮点击时读 webLoadTime 算 duration 再上抛
/// 老架构 HSSInterstitialVC.webLoadTime 的 2.0 等价物
@property (nonatomic, assign, readonly) NSTimeInterval webLoadTime;

@end

NS_ASSUME_NONNULL_END
