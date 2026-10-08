//
//  HSSSkoverlayModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2024/12/12.
//

#import "HSSBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HSSSkoverlayModel : HSSBaseModel

/// sk弹窗位置  0 = bottom, 1 = bottomRaised
@property (nonatomic, assign) NSInteger position;

/// 用户是否可以取消sk弹窗，0 = 否，1 = 是
/// 客户端默认：1
@property (nonatomic, assign) NSInteger dismissable;

/// 视频播放后，多久自动弹出sk弹窗 无字段：不自动弹窗 0：视频开始播放则自动弹出 其他大于0：视频播放到指定时间，自动弹出
/// 客户端默认：-1，不自动弹窗
@property (nonatomic, assign) NSInteger video_delay;

/// 广告渲染展示后，多久自动弹出sk弹窗 无字段：不自动弹窗 0：广告展示则自动弹出 其他大于0：广告展示到指定时间，自动弹出
/// 客户端默认：-1，不自动弹窗
@property (nonatomic, assign) NSInteger delay;

/// 基于sk_dismiss_delay再次展示Overlay 当检测到用户已退出StoreKit全屏页面：
/// 如果sk_dismiss_delay已设置为N（N为正整数），则客户端在N秒后再次展示Overlay。
/// 如果sk_dismiss_delay未设置(null)，则不进行此步骤，不再次展示Overlay。
/// 如果sk_dismiss_delay已设置为0，则客户端在0秒后再次展示Overlay
/// 客户端默认：-1，不自动弹窗
@property (nonatomic, assign) NSInteger sk_dismiss_delay;

/// 展示endcard后，多久自动弹出sk弹窗
/// 无字段：不自动弹窗
/// 0：广告展示则自动弹出
/// 其他大于0：广告展示到指定时间，自动弹出
/// 客户端默认：-1，不自动弹窗
@property (nonatomic, assign) NSInteger endcarddelay;

/// 客户端默认：空
@property (nonatomic, strong) id ext;

@end

NS_ASSUME_NONNULL_END
