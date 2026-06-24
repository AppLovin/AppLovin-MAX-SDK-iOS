//
//  HSSAdMaterial.h
//  HSADXSDK
//
//  Created by admin on 2024/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdMaterial : NSObject

/// 广告组
@property (nonatomic, copy, readonly) NSString *dspName;

/// 图标 url
@property (nonatomic, copy, readonly) NSString *iconUrl;

/// 图片内容 url
@property (nonatomic, copy, readonly) NSString *imgUrl;

/// deeplink
@property (nonatomic, copy, readonly) NSString *deeplink;

/// 落地页
@property (nonatomic, copy, readonly) NSString *landingUrl;

/// 素材Id
@property (nonatomic, copy, readonly) NSString *cRid;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
