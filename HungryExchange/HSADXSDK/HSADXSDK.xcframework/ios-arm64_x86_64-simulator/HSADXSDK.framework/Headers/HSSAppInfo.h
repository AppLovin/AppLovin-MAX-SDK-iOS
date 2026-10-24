//
//  HSSAppInfo.h
//  HSADXSDK
//
//  Created by admin on 2024/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAppInfo : NSObject

/// 外部配置
@property (nonatomic, copy, readonly) NSString *appToken;

/// 应用名称
@property (nonatomic, copy, readonly) NSString *appName;

/// SKAdNetworkItems
@property (nonatomic, copy, readonly) NSArray *nidList;

/// 个性化广告设置： 0-不允许，1-允许
@property (nonatomic, assign, readonly) NSInteger personlizedAd;

/// 广告SDK版本号
@property (nonatomic, copy, readonly) NSString *sdkVersion;

/// 应用版本号-字符串 1.2.3.4
@property (nonatomic, copy, readonly) NSString *versionName;

/// 应用包名 com.demo_test.hs
@property (nonatomic, copy, readonly) NSString *packageName;

/// ATTracking 权限
@property (nonatomic, assign, readonly) NSInteger atts;

/// userAgent
@property (nonatomic, copy, readonly) NSString *ua;

/// 运行时长
@property (nonatomic, assign, readonly) NSInteger appRuningTime;

/// 启动次数
@property (nonatomic, assign, readonly) NSInteger appOpenCnt;

/// versionCode
@property (nonatomic, copy, readonly) NSString *versionCode;

/// 用户安装时间戳（秒）
@property (nonatomic, copy, readonly) NSString *installTime;

/// gdpr Tc参数，客户端获取
@property (nonatomic, copy, readonly) NSString *gdprTc;
@property (nonatomic, copy, readonly) NSString *gpp;
@property (nonatomic, copy, readonly) NSString *gpp_sid;
@property (nonatomic, assign, readonly) NSInteger do_not_sell;
/// 命中实验方案号
@property (nonatomic, copy, readonly) NSString *adWayNum;
//内推场景专用，其他场景不能使用此字段， 否则会有覆盖问题
@property (nonatomic, copy, readonly) NSString *promoteAdWayNum;
//内推场景专用，其他场景不能使用此字段， 否则会有覆盖问题
@property (nonatomic, copy, readonly) NSString *productAdWayNum;

// 关联某次冷启动全部事件的
@property (nonatomic, copy, readonly) NSString *sessionID;

+ (instancetype)shared;

+ (void)hss_configure:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
