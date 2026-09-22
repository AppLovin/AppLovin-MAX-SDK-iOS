//
//  HSSURLValidator.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/6.
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

/// URL 校验器：负责 URL 识别、验证、提取
@interface HSSURLValidator : NSObject

#pragma mark - URL 类型判断

/// 判断是否为有效的 Deeplink（非 HTTP/HTTPS，且包含有效 scheme）
+ (BOOL)isValidDeeplink:(NSString *)urlString;

/// 判断是否为 App Store 链接（包含apple.com且能解析出appId ）
+ (BOOL)canParseAppStoreId:(NSString *)urlString;

/// 判断是否为 App Store 链接（包含 apps.apple.com ）
+ (BOOL)isAppStoreURL:(NSString *)urlString;

/// 判断是否为 HTTP/HTTPS 链接
+ (BOOL)isHTTPURL:(NSString *)urlString;

/// 判断系统是否可以打开该 URL
+ (BOOL)canOpenURL:(NSURL *)url;

#pragma mark - URL 提取

/// 从 Creative 中提取 Deeplink URL
+ (nullable NSString *)extractDeeplinkURL:(nullable HSSCreativeItemModel *)creative;

/// 从 Creative 中提取 Landing URL
+ (nullable NSString *)extractLandingURL:(nullable HSSCreativeItemModel *)creative;

/// 从 Creative 中提取 VAST Click URL
+ (nullable NSString *)extractVastClickURL:(nullable HSSCreativeItemModel *)creative;

/// 从 App Store URL 中提取 App Store ID（如：id123456789 → @"123456789"）
+ (nullable NSString *)extractAppStoreID:(NSString *)appStoreURL;

#pragma mark - Creative 配置判断

/// 判断是否应使用内置浏览器（web_type = 1）
+ (BOOL)shouldUseInAppBrowser:(nullable HSSCreativeItemModel *)creative;

/// 判断内置浏览器是否需要跳转后自动关闭（web_inner_close = 1）
+ (BOOL)shouldCloseInAppBrowserAfterRedirect:(nullable HSSCreativeItemModel *)creative;

/// 获取deeplink跳转后上报链接
+ (NSString *)app_install_url:(HSSCreativeItemModel *)creative;
@end

NS_ASSUME_NONNULL_END
