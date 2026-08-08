//
//  HSSSKAutoStoreModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/6/19.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSSKAutoStoreModel : HSSBaseModel

/// 是否开启 AutoStoreView， 0否 1是
@property (nonatomic, assign) NSInteger enabled;

/// 应用 id
@property (nonatomic, copy) NSString *appId;

/// 是否展示商店时触发点击链接上报，0不触发  1触发
@property (nonatomic, assign) NSInteger click;

@end

NS_ASSUME_NONNULL_END
