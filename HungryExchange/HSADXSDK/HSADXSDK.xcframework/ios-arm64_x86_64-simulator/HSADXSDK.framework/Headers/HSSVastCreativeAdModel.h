//
//  HSSVastCreativeModel.h
//  HSADXSDK
//
//  Created by admin on 2024/12/14.
//

#import <Foundation/Foundation.h>

@class HSSVideoVerificationParameters;
@class HSSItemImageModel;
@class HSSVastCreativeCompanionAdsModel;

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastCreativeAdModel : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *desInfo;
@property (nonatomic, copy, nullable) NSString *extensionPixel;
@property (nonatomic, assign) NSTimeInterval expire;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy, nullable) NSNumber *displayDurationInSeconds;
@property (nonatomic, strong, nullable) NSNumber *skipOffset;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy, nullable) NSString *html;
@property (nonatomic, copy, nullable) NSString *targetURL;
@property (nonatomic, copy, nullable) NSString *videoFileURL;
/// VAST MediaFile.type（如 video/mp4）。用于流式播放时提供给 AVAssetResourceLoader 的 ContentType。
@property (nonatomic, copy, nullable) NSString *videoMimeType;
@property (nonatomic, copy, nullable) NSString *revenue;
@property (nonatomic, strong, nullable) HSSVideoVerificationParameters* verificationParameters;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *trackingURLs;

@property (nonatomic, copy, nullable) NSString *adTrackingTemplateURL;

@property (nonatomic, copy, nullable) NSString *clickThroughURL;
@property (nonatomic, assign) BOOL isCompanionAd;
@property (atomic, assign) bool hasCompanionAd;

// NOTE: for rewarded ads only
@property (nonatomic, assign) BOOL userHasEarnedReward;
@property (nonatomic, assign) BOOL userPostRewardEventSent;

@property (nonatomic, strong, nullable) NSNumber * rewardTime;
@property (nonatomic, strong, nullable) NSNumber * postRewardTime;

@property (nonatomic, strong) HSSItemImageModel *icon;

@property (nonatomic, strong) HSSVastCreativeCompanionAdsModel *companionAds;

/// 仅当通过 hss_modelWithResolvedDictionary: 从 hss_vast_resolved 恢复时赋值（预解析落盘后再取出）。
/// 正常 buildAds 解析成功路径请勿赋值，以便用 originalVastType 是否有效区分 resolved 素材与现场解析。
/// 取值 Inline / Wrapper：resolved 后形态已展开时仍保持 adx_sdk_vast_* 的 vast_type 与线上一致。
@property (nonatomic, copy, nullable) NSString *originalVastType;

/// 持久化为 hss_vast_resolved 字典
- (NSDictionary *)hss_resolvedDictionaryWithIsAdxUniTmpl:(BOOL)isAdxUniTmpl
                                                vastType:(nullable NSString *)vastType;

/// 从 hss_vast_resolved 字典恢复运行时模型
+ (nullable instancetype)hss_modelWithResolvedDictionary:(NSDictionary *)resolved;

@end

NS_ASSUME_NONNULL_END
