//
//  HSSShowAtNsReporter.h
//  HSADXSDK
//
//  通用：前台连续可见累计满 N ms 后上报一次；退后台暂停；回前台续跑补齐剩余时间
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 通用：按 dsp enableList 判断是否允许上报
/// - enableList: @"all" 或用 "_" 分隔的 dspName 列表（空/非法 -> NO）
/// - dspName: 当前广告的 dsp_name（空 -> NO）
FOUNDATION_EXPORT BOOL HSSShouldReportForDspEnableList(NSString * _Nullable enableList,
                                                       NSString * _Nullable dspName);

/// Show-at-N-seconds 埋点事件名（Banner/插屏/激励统一使用同一事件名，通过属性区分广告类型）
FOUNDATION_EXPORT NSString *const HSSAdxSdkShowAtNsEventName;

@interface HSSShowAtNsReporter : NSObject

/// 是否允许上报（例如：dsp 白名单开关）
@property (nonatomic, copy) BOOL (^enabledProvider)(void);

/// 获取阈值毫秒数（<=0 使用默认值 1000ms）
@property (nonatomic, copy) NSInteger (^delayMsProvider)(void);

/// 当前是否处于 window 且可见（建议包含 window + 可见区域判断）
@property (nonatomic, copy) BOOL (^visibleProvider)(void);

/// 埋点参数提供者（由调用方决定具体字段）
@property (nonatomic, copy) NSDictionary * _Nullable (^paramsProvider)(void);

/// 真正上报动作（由调用方决定 tracker 名称/上报实现）
@property (nonatomic, copy) void (^reporter)(NSDictionary *params);

/// 展示开始时调用：若满足条件则启动/续跑；只会上报一次
- (void)startIfNeeded;

/// 视图移出 window 或重置时调用：停止并清空状态（下次展示重新计时）
- (void)stopAndReset;

@end

NS_ASSUME_NONNULL_END

