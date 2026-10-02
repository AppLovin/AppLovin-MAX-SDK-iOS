//
//  HSSActionRouter.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import <Foundation/Foundation.h>

@class HSSActionModel;
@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

extern NSString *HSSAppStorePresentNotification;

typedef void(^actionCompletionBlock)(BOOL result, NSString *_Nullable deeplinkUrl);

@interface HSSActionRouter : NSObject
+(void)hss_actionRouter:(HSSActionModel *)action;

+(void)hss_actionRouter:(HSSActionModel *)action completionBlock:(nullable void (^)(id __nullable params))block;

+(void)hss_adActionRouter:(HSSCreativeItemModel *)adModel;

+(void)hss_adActionRouter:(HSSCreativeItemModel *)adModel completionBlock:(actionCompletionBlock)block;

+ (void)hss_adActionRouterForCrossPromotionWithID:(NSString *)appID urlSession:(NSURLSession *)urlSession clickURL:(NSURL *)clickURL parameters:(NSDictionary *)parameters completionBlock:(actionCompletionBlock)block;

+ (void)hss_actionAppStore:(NSDictionary *)productParams completionBlock:(actionCompletionBlock)block;

+ (void)hss_actionUrlString:(NSString *)string creativeModel:(HSSCreativeItemModel *)creativeModel completionBlock:(actionCompletionBlock)block;

+ (void)hss_actionUrlStringFromBanner:(NSString *)string creativeModel:(HSSCreativeItemModel *)creativeModel completionBlock:(actionCompletionBlock)block;

+ (void)hss_actionUrlStringFromInterstitialBanner:(NSString *)string creativeModel:(HSSCreativeItemModel *)creativeModel completionBlock:(actionCompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
