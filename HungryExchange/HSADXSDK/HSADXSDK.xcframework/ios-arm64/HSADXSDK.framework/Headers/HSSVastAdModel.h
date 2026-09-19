//
//  HSSVastModel.h
//  HSADXSDK
//
//  Created by admin on 2024/12/3.
//

#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN


/// vast InLine ->Creatives ->Creative->Linear -> Icons
@interface HSSVastIconModel : HSSBaseModel

@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, copy)  NSString *iconUrl;

@end


/// vast InLine ->Creatives ->Creative->Linear -> TrackingEvents
@interface HSSVastTrackingModel : HSSBaseModel

/// 事件名称
@property (nonatomic, copy) NSString *event;

/// 事件追踪 url
@property (nonatomic, copy) NSString *url;

@end

/// vast InLine ->Creatives ->Creative->Linear -> VideoClicks
@interface HSSVastVideoClicksModel : HSSBaseModel

/// 点击事件 urls
@property (nonatomic, copy) NSArray *clickThrough;

/// 点击追踪 urls
@property (nonatomic, copy) NSArray *clickTracking;

@end

/// vast InLine ->Creatives ->Creative->Linear -> Mediafiles
@interface HSSVastMediafileModel : HSSBaseModel

/// 视频 url
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *delivery;
@property (nonatomic, copy) NSString *type;

/// 视频宽度
@property (nonatomic, assign) NSInteger width;

/// 视频高度
@property (nonatomic, assign) NSInteger height;

@end



/// vast InLine ->Creatives -> Creative
@interface HSSVastCreativeModel : HSSBaseModel

@property (nonatomic, copy)   NSString *Id;

/// icon
@property (nonatomic, strong) NSArray<HSSVastIconModel*> *icons;

/// 追踪事件
@property (nonatomic, strong) NSArray<HSSVastTrackingModel *>*trackingEvents;

/// 视频时长
@property (nonatomic, copy)   NSString *duration;

/// 过期时间(分钟)
@property (nonatomic, assign) NSInteger expires;

/// 视频点击事件
@property (nonatomic, strong) HSSVastVideoClicksModel *videoClicks;

/// 媒体播放素材
@property (nonatomic, strong) NSArray<HSSVastMediafileModel*> *mediaFiles;

/// 本地记录加载时间,用于判断是否过期
@property (nonatomic, assign)  NSTimeInterval loadTime;

///手动添加
@property (nonatomic, copy) NSArray *videoUrls;
@end

/// vast InLine 下面节点
@interface HSSVastAdModel : HSSBaseModel

/// title
@property (nonatomic, copy) NSString *adTitle;

/// 来源
@property (nonatomic, copy) NSString *adSystem;

/// 描述
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *survey;

/// 广告素材内容
@property (nonatomic, strong) HSSVastCreativeModel *creative;

-(BOOL)isValidVast;

@end

NS_ASSUME_NONNULL_END
