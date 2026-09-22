//
//  HSSCrashReportManager.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSCrashReportManager : NSObject

/// 单例
+ (instancetype)sharedManager;

///  存储每次广告展示的相关信息，每次新的展示信息覆盖旧的信息
- (void)saveAdContextWithParams:(NSDictionary *)params;

/// 设置广告ad崩溃上报开关
- (void)setAdCrashSwitch:(NSInteger)crashSwitch;

/// 设置广告ad崩溃的标志
- (void)setAdCrashFlag;

/// 清除ad崩溃的标志
- (void)clearAdCrashFlag;

/// 上报到服务器
- (void)reportAdxCrashIfNeededWithParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
