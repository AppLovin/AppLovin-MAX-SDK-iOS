//
//  HSSVastCreativeCompanionAdsModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/6/20.
//

#import <HSADXSDK/HSADXSDK.h>

typedef NS_ENUM(NSInteger, HSSVastCompanionResourceType) {
    HSSVastCompanionResourceTypeStaticResource,
    HSSVastCompanionResourceTypeIFrameResource,
    HSSVastCompanionResourceTypeHtmlResource,
};

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastCreativeCompanionAdsModel : NSObject

/// 图片地址
@property (nonatomic, copy) NSString *url;

/// 图片宽 px
@property (nonatomic, assign) NSInteger width;

/// 图片高 px
@property (nonatomic, assign) NSInteger height;

@property (nonatomic, copy, nullable) NSString *clickThroughURL;

@property (nonatomic, strong) NSArray<NSString *> *trackingURLs;

@property (nonatomic, assign) HSSVastCompanionResourceType resourceType;

@end

NS_ASSUME_NONNULL_END
