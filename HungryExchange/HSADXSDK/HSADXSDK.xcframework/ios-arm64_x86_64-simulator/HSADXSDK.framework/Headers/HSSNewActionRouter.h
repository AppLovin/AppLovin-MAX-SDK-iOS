//
//  HSSNewActionRouter.h
//  HSADXSDK
//
//  Created by 张松 on 2025/12/2.
//

#import <Foundation/Foundation.h>

@class HSSActionModel;
@class HSSCreativeItemModel;
@class HSSJumpTrackingContext;

NS_ASSUME_NONNULL_BEGIN

extern NSString *HSSNewActionAppStorePresentNotification;
extern NSString *HSSInnerWebVCWillAppearNotification;        // InnerWebVC 将要显示，暂停视频
extern NSString *HSSInnerWebVCDidDisappearNotification;      // InnerWebVC 已消失，恢复视频

/// 跳转完成回调
/// @param result 跳转是否成功
/// @param deeplinkUrl 跳转的URL（可选）
/// @param context 跳转追踪上下文（可选）- 包含完整的跳转过程信息，用于 adx_sdk_click_result 埋点
typedef void(^actionNewCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl, HSSJumpTrackingContext *_Nullable context);

typedef void(^actionClickBlock)(void);  // 点击回调

@interface HSSNewActionRouter : NSObject

/**
 统一跳转入口（带防重检查）
 
 @param creative 广告素材模型（必填）
 @param clickBlock 点击回调（可选）- 只在非重复点击时触发，用于上报点击埋点
 @param completion 跳转完成回调（可选）- 跳转结果回调，用于上报结果埋点
 
 执行流程：
 1. 防重检查 → 如果重复，直接返回，不触发任何回调
 2. clickBlock() → 外部上报埋点
 3. 执行跳转逻辑
 4. completion(result, url) → 返回跳转结果
 */
+ (void)hss_adClickActionRouter:(HSSCreativeItemModel *)creative
                      clickBlock:(nullable actionClickBlock)clickBlock
                      completion:(nullable actionNewCompletionBlock)completion;

+ (void)hss_adClickActionRouterWithUrl:(NSString *)url
                         creativeModel:(HSSCreativeItemModel *)creative
                            clickBlock:(nullable actionClickBlock)clickBlock
                            completion:(nullable actionNewCompletionBlock)completion;

/**
 @param url 外部传入的url
 @param creative 广告素材模型（必填）
 @param completion 完成回调（可选）
 
 功能：
 - 判断URL（优先级：url>deeplink_url > landing_url > vast.clickThroughURL）
 - 自动处理 SKAdNetwork 参数跳转
 - 自动判断 URL 类型：Deeplink/App Store  / 普通 URL
 
 使用场景：Banner。替代之前hss_actionUrlString、hss_actionUrlStringFromBanner、hss_actionUrlStringFromInterstitialBanner
 */
+ (void)hss_adClickActionRouterWithUrl:(NSString *)url
                         creativeModel:(HSSCreativeItemModel *)creative
              completion:(nullable actionNewCompletionBlock)completion;

/**
 @param creative 广告素材模型（必填）
 @param completion 完成回调（可选）
 
 功能：
 - 自动从 Creative 提取 URL（优先级：deeplink_url > landing_url > vast.clickThroughURL）
 - 自动处理 SKAdNetwork 参数跳转
 - 自动判断 URL 类型：Deeplink/App Store / 普通 URL
 
 使用场景：Banner/Interstitial/Rewarded 广告点击
 */
+ (void)hss_adClickActionRouter:(HSSCreativeItemModel *)creative
              completion:(nullable actionNewCompletionBlock)completion;



/// 用于外部自动弹出 App Store 商店页（原方法，原逻辑，暂不做改动）
+ (void)hss_newActionAppStore:(NSDictionary *)productParams completionBlock:(actionNewCompletionBlock)block;

/// 原方法，暂不做改动
+ (void)hss_newAdActionRouterForCrossPromotionWithID:(NSString *)appID urlSession:(NSURLSession *)urlSession clickURL:(NSURL *)clickURL parameters:(NSDictionary *)parameters completionBlock:(actionNewCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
