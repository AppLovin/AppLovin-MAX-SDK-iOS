//
//  HSSDeviceInfo.h
//  HSADXSDK
//
//  Created by admin on 2024/11/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HSSConfigureModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSDeviceInfo : NSObject

/// 设备类型
@property (nonatomic, readonly, assign) NSInteger type;

/// 系统类型：android/ios， 全小写
@property (nonatomic, readonly, copy) NSString *os;

/// 系统类型：android/ios， 全小写
@property (nonatomic, readonly, copy) NSString *osVersion;

/// 苹果广告id
@property (nonatomic, readonly, copy) NSString *idfa;

/// iOS dev标识符
@property (nonatomic, readonly, copy) NSString *idfv;

/// 手机品牌
@property (nonatomic, readonly, copy) NSString *vendor;

/// 手机型号
@property (nonatomic, readonly, copy) NSString *model;

/// 网络类型 0：unknown 1：Ethernet 2：WI-FI 3：手机网络，未知制式 4：2G 5：3G 6：4G 7：5G
@property (nonatomic, readonly, assign) NSInteger net;

/// 屏幕宽，单位px
@property (nonatomic, readonly, assign) NSInteger screenWidth;

/// 屏幕高，单位px
@property (nonatomic, readonly, assign) NSInteger screenHeight;

/// 屏幕缩放比
@property (nonatomic, readonly, assign) NSInteger screenScale;

/// 设备时区
@property (nonatomic, readonly, copy) NSString *timeZone;

/// 设备时区偏移量 单位分钟
@property (nonatomic, readonly, assign) NSInteger offset;

/// 设备首选语言
@property (nonatomic, readonly, copy) NSString *language;

/// 设备地区语言
@property (nonatomic, readonly, copy) NSString *localeLanguage;

/// 设备内存数量，单位字节，byte
@property (nonatomic, readonly, assign) NSInteger totalMem;

/// 屏幕是否关闭：0-未关闭、1-关闭
@property (nonatomic, readonly, assign) NSInteger cpuNum;

/// 电池剩余电量，[0,100]
@property (nonatomic, readonly, assign) NSInteger batteryRemainingPct;

/// 是否在充电，0-为充电：1-充电中
@property (nonatomic, readonly, assign) NSInteger isCharging;

/// 总储存空间
@property (nonatomic, readonly, assign) NSInteger totalSpace;

/// 是否root：0-未root，1-已root
@property (nonatomic, readonly, assign) NSInteger root;

/// 是否开启省点模式：0-未开启，1-已开启
@property (nonatomic, readonly, assign) NSInteger lowPowerMode;

/// 英寸分辨率点数
@property (nonatomic, readonly, assign) NSInteger dpi;

/// 屏幕分辨率 宽x高
@property (nonatomic, readonly, copy) NSString *screenResolution;

/// 移动网络标识符
@property (nonatomic, readonly, copy) NSString *mccmnc;

/// 移动网络运营商名称
@property (nonatomic, readonly, copy) NSString *carrier;

/// 设备硬件型号 eg:iPhone11,6
@property (nonatomic, readonly, copy) NSString *deviceModel;

/// 设备内部型号代码
@property (nonatomic, readonly, copy) NSString *deviceType;

/// 支持所有SkAdNetwork版本号
@property (nonatomic, readonly, copy) NSArray *skanVersions;

/// 屏幕亮度
@property (nonatomic, readonly, assign) CGFloat screenBright;



/// 设备开机时间戳，毫秒级
@property (nonatomic, readonly, assign) uint64_t boot;

/// 屏幕是否关闭：0-未关闭、1-关闭
@property (nonatomic, readonly, assign) NSInteger isScreenOff;

/// 开机时间（累计时间），毫秒级
@property (nonatomic, readonly, assign) uint64_t powerOnTime;

/// 系统编译时间
@property (nonatomic, readonly, assign) uint64_t sysCompillingTime;

/// cpu最大频率
@property (nonatomic, readonly, assign) NSInteger cpuMaxFreq;

/// cpu最小频率
@property (nonatomic, readonly, assign) NSInteger cpuMinFreq;

/// iOS系统更新时间，最后一次升级时间，秒时间戳
@property (nonatomic, readonly, assign) NSInteger pb;

/// iOS的编译版本
@property (nonatomic, readonly, copy) NSString *sysBuildVersion;

/// 设备局域网ip
@property (nonatomic, readonly, copy) NSString *ip;

/// 展示状态
@property (nonatomic, readonly, assign) NSInteger displayType;

/// app安装状态
@property (nonatomic, readonly, strong) NSDictionary *appInstallInfo;

/// 设备维度唯一标识
@property (nonatomic, readonly, copy) NSString *deviceFingerprint;

/// OpenRTB device.sua（结构化 UA，由 HSSSUABuilder 拼装）
@property (nonatomic, readonly, copy) NSDictionary *sua;

+ (instancetype)shared;

- (void)startAppsDetection;

@end

NS_ASSUME_NONNULL_END
