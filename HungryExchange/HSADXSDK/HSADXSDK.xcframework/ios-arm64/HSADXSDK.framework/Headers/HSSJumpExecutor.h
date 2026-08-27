//
//  HSSJumpExecutor.h
//  HSADXSDK
//
//  Created by 张松 on 2025/11/6.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSCreativeItemModel.h>

NS_ASSUME_NONNULL_BEGIN

/// 跳转错误码
typedef NS_ENUM(NSInteger, HSSJumpExecutorErrorCode) {
    // URL 相关错误 (1xxx)
    HSSJumpExecutorErrorCodeURLEmpty = 1001,          // URL 为空
    HSSJumpExecutorErrorCodeURLInvalid = 1002,        // URL 格式错误
    HSSJumpExecutorErrorCodeSystemOpenFailed = 1003,  // 系统打开失败
    
    // App Store 相关错误 (2xxx)
    HSSJumpExecutorErrorCodeAppStoreParamsInvalid = 2001,        // App Store 参数无效
    HSSJumpExecutorErrorCodeAppStoreNoViewController = 2002,     // 找不到 ViewController
    HSSJumpExecutorErrorCodeAppStoreLoadFailed = 2003,           // App Store 加载失败
    HSSJumpExecutorErrorCodeAppStoreVersionNotSupported = 2004,  // iOS 版本不支持
    HSSJumpExecutorErrorCodeAppStoreIDInvalid = 2005,            // App Store ID 无效
    
    // 内置浏览器相关错误 (3xxx)
    HSSJumpExecutorErrorCodeInnerWebURLEmpty = 3001,  // 内置浏览器 URL 为空
};

/// 跳转完成回调，如果是失败，需要设置error_code和error_msg
typedef void(^HSSJumpCompletionBlock)(BOOL success, NSString * _Nullable url, NSError * _Nullable error);
static NSString * const HSSJumpExecutorErrorDomain = @"com.hsadx.jumpexecutor";

/// 跳转执行器：负责底层跳转操作
@interface HSSJumpExecutor : NSObject

#pragma mark - 系统跳转

/// 使用系统方式打开 URL（Deeplink / HTTP）
+ (void)openURLWithSystem:(NSString *)urlString
               completion:(nullable HSSJumpCompletionBlock)completion;

#pragma mark - 内置浏览器

/// 使用内置 WebView 打开 URL
+ (void)openURLWithInnerWebview:(NSString *)urlString
                  creativeModel:(HSSCreativeItemModel *)creativeModel
                     completion:(nullable HSSJumpCompletionBlock)completion;

#pragma mark - App Store

/// 弹出 App Store 商店页（SKStoreProductViewController）
/// @param productParams 商店参数字典（必须包含 SKStoreProductParameterITunesItemIdentifier）
+ (void)presentAppStore:(NSDictionary *)productParams
             completion:(nullable HSSJumpCompletionBlock)completion;

/// 处理 App Store URL 跳转（自动提取 ID 并弹出商店页）
+ (void)handleAppStoreURL:(NSString *)appStoreURL
               completion:(nullable HSSJumpCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
