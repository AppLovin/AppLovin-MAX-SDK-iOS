//
//  HSADXMacro.h
//  Pods
//
//  Created by admin on 2024/11/19.
//

#ifndef HSSADXMacro_h
#define HSSADXMacro_h
#import <HSADXSDK/NSString+HSSExtension.h>
#import <HSADXSDK/HSSTracker.h>

/// SDK 版本号（必须 3 段）
/// 约束：每段取值范围 [0, 99]；单段不得 ≥ 100，patch 升到 99 后必须进位（如 1.0.99 → 1.1.0）
/// 请求参数 sdk_version_code 由 HSSNetGeneral 自动按 major*10000 + minor*100 + patch 计算（例：1.2.1 → 10201）
#define HSSdkVersion  @"1.2.36"


//返回布尔值: string是否为空、空对象
#define isNullString(string) [NSString isNullString:string]

//返回非空字符串!!!
#define NonNULLString(string) [NSString NonNULLString:string]

#define weakify(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define strongify(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

/// 回调给外部
#define HSSdkTracker(eventName,paramsDict) [HSSTracker hss_tracker:eventName params:paramsDict];

/// 本地控制采样频率
#define HSSdkSamplingTracker(eventName,paramsDict) [HSSTracker hss_samplingTracker:eventName params:paramsDict];

#define HSSdkSamplingTenPercentTracker(eventName,paramsDict) [HSSTracker hss_tenPercentSamplingTracker:eventName params:paramsDict];

#endif /* HSADXMacro_h */

#if DEBUG || BETA
# define HSSLoger(fmt, ...) NSLog((@"ADX:::[Method:%s] [Line:%d]" fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define HSSLoger(...);
#endif

// MARK: - 系统版本判断宏

/// 判断系统版本是否大于等于指定版本
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

/// 判断系统版本是否小于指定版本
#define SYSTEM_VERSION_LESS_THAN(v) \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// MRK: - 宏定义
#define HSSVastTypeInline  @"Inline"

#define HSSVastTypeWrapper @"Wrapper"
