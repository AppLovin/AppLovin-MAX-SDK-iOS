//
//  NSMutableURLRequest+HSSRequest.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSNetworkConstant.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest (HSSRequest)

+ (NSMutableURLRequest *_Nullable)hs_RequestWithURL:(NSURL *_Nonnull)URL
                                             method:(HSSRequestMode)method
                                         parameters:(id _Nullable)parameters
                                               body:(NSData*_Nullable)body
                                             header:(NSDictionary *_Nullable)header
                                              error:(NSError * _Nullable __autoreleasing *_Nullable)error;

+ (NSMutableURLRequest *_Nullable)hs_EncryptRequestWithURL:(NSURL *_Nonnull)URL
                                             method:(HSSRequestMode)method
                                         parameters:(id _Nullable)parameters
                                             header:(NSDictionary *_Nullable)header
                                              error:(NSError * _Nullable __autoreleasing *_Nullable)error;

+ (NSMutableURLRequest *)hs_RequestWithURL:(NSURL *)URL;

/// 新安全协议：绑定本次请求随机生成的 AES 密钥，供响应解密使用。
+ (void)hss_setAesKey:(NSData *)aesKey forRequest:(NSMutableURLRequest *)request;

/// 读取请求绑定的 AES 密钥；未使用新加密时为 nil。
+ (nullable NSData *)hss_aesKeyForRequest:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
