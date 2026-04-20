//
//  HSSAd.h
//  HSADXSDK
//
//  Created by admin on 2024/11/27.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdFormat.h>

@class HSSAdMaterial;
@class HSSAdAttribute;

NS_ASSUME_NONNULL_BEGIN

@interface HSSAd : NSObject

/// 请求广告 id
@property (nonatomic, copy, readonly) NSString *placementId;

/// 加载网络广告源
@property (nonatomic, copy, readonly) NSString *networkName;

/// 加载网络广告位置
@property (nonatomic, copy, readonly) NSString *networkPlacement;

/// ad 格式
@property (nonatomic, assign, readonly) HSSAdFormatType adFormat;

/// ad ecpm
@property (nonatomic, assign, readonly) double ecpm;

/// ad 素材
@property (nonatomic, strong, readonly) HSSAdMaterial *adMaterial;

/// 此类用于给AppsFlyer提供归因数据
@property (nonatomic, strong, readonly) HSSAdAttribute *adAttribute;

/// 请求id  adx sdk 请求后端server时都会生成一个id
@property (nonatomic, copy, readonly) NSString *rid;

@property (nonatomic, copy, readonly) NSString *open_app;

@property (nonatomic, copy, readonly) NSString *open_app_id;

@property (nonatomic, assign, readonly) BOOL isLocal;

@property (nonatomic, assign, readonly) BOOL isOffline;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
