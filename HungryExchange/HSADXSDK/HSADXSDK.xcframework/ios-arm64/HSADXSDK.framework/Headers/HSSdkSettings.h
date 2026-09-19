//
//  HSSdkSettings.h
//  HSADXSDK
//
//  Created by admin on 2024/11/25.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdTrackerDelegate.h>
NS_ASSUME_NONNULL_BEGIN

@interface HSSdkSettings : NSObject

/// sdk 内部打点, 默认是内部上报, 如果设置指定外部上报, 内部不参与
@property (nonatomic, weak) id<HSSAdTrackerDelegate> trackerDelegate;

/// 视频广告静音设置 YES 静音 NO 非静音， 默认 NO
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/// 当前用户唯一标识
@property (nonatomic, copy, nullable) NSString *userIdentifier;

/// 唯一标识
@property (nonatomic, copy, nullable) NSString *distinctId;

/// 用户安装时间戳（秒）
@property (nonatomic, copy, nullable) NSString *install_ts;

/// 额外参数
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *extraParameters;

/// 是否切换到debug模式
@property (nonatomic, assign) BOOL debugMode;

@property (nonatomic, copy, readonly) NSString *adWayNum;

/// 是否开启内部自动重试
/// NO：并不一定意味着会自动重试，是否自动重试还需要首adx服务端控制
/// YES：一定会关闭内部的自动重试
@property (nonatomic, assign) BOOL disableAutoRetry;

@end

NS_ASSUME_NONNULL_END
