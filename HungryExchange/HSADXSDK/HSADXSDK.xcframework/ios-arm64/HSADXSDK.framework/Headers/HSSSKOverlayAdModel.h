//
//  HSSSKOverlayAdModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/6/19.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSSKOverlayAdModel : HSSBaseModel

/// 是否开启 skoverlay， 0否 1是
@property (nonatomic, assign) NSInteger enabled;

/// 是否支持用户主动关闭， 0否 1是
@property (nonatomic, assign) NSInteger dismissible;

/// 延迟出现秒数，0则立即弹出
@property (nonatomic, assign) NSInteger delay;

/// 出现位置，0 = bottom, 1 = bottom raised
@property (nonatomic, assign) NSInteger pos;

/// 应用 id
@property (nonatomic, copy) NSString *appId;

/// 是否触发click埋点， 0:触发， 1:不触发
@property (nonatomic, assign) NSInteger click;


@end

NS_ASSUME_NONNULL_END
