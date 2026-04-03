//
//  HSSMaxBiddingManager.h
//  HSADXSDK
//
//  Created by 张松 on 2025/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Max Bidding 广告类型
typedef NS_ENUM(NSInteger, HSSMaxBiddingAdType) {
    HSSMaxBiddingAdTypeInterstitial = 1,  // 插屏广告
    HSSMaxBiddingAdTypeRewarded = 2,       // 激励视频广告
    HSSMaxBiddingAdTypeBanner320_50 = 3,
    HSSMaxBiddingAdTypeBanner300_50 = 4,
};


/**
 * Max Bidding 管理器
 * 提供Max S2S Bidding集成所需的接口
 *
 * 使用流程：
 * 1. Max Adapter调用 getBiddingToken 获取token
 * 2. Max将token发送到服务器进行竞价
 * 3. Max服务器请求广告服务器，返回广告数据
 * 4. Max Adapter调用 loadAdWithMaxBidResponse 加载广告
 */
@interface HSSMaxBiddingManager : NSObject

/**
 * 获取用于Max Bidding的Token（通用）
 * 该Token包含设备信息、应用信息等，已压缩并Base64编码
 * 
 *
 * @return Bidding Token字符串，失败返回nil
 */
+ (nullable NSString *)getBiddingToken;

/**
 * 获取指定广告位的Bidding Token（推荐使用）
 * 相比通用方法，会包含placementId和adType等额外信息
 *
 * @param placementId 广告位ID
 * @param adType 广告类型：1、inter   2、reward    3、banner (320,50)   4、banner (300, 50)
 * @return Bidding Token字符串，失败返回nil
 */
+ (nullable NSString *)getBiddingTokenForPlacement:(NSString *)placementId
                                            adType:(HSSMaxBiddingAdType)adType;

/**
 * 获取指定广告位的Bidding Token（带额外参数）
 *
 * @param placementId 广告位ID
 * @param adType 广告类型：1、inter   2、reward    3、banner (320,50)   4、banner (300, 50)
 * @param extraParams 额外参数（可选），会合并到最终的token中
 * @return Bidding Token字符串，失败返回nil
 */
+ (nullable NSString *)getBiddingTokenForPlacement:(NSString *)placementId
                                            adType:(HSSMaxBiddingAdType)adType
                                       extraParams:(nullable NSDictionary<NSString *, id> *)extraParams;


/**
 * 验证BidResponse是否有效
 *
 * @param bidResponse Max返回的BidResponse字符串
 * @return YES表示有效，NO表示无效
 */
+ (BOOL)isValidBidResponse:(NSString *)bidResponse;

// 通用方法：将NSDictionary压缩并Base64编码
+ (NSString *)compressAndBase64EncodeDictionary:(NSDictionary *)dictionary;

// 通用方法：Base64解码并解压缩为NSDictionary
+ (NSDictionary *)base64DecodeAndDecompressToDictionary:(NSString *)base64String;
@end

NS_ASSUME_NONNULL_END
