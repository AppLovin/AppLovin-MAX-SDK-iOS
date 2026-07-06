//
//  HSSNetSecureResponse.h
//  HSADXSDK
//
//  新安全协议（HSSCryptoCipher）响应解密
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSNetSecureResponse : NSObject

/// use_new_security_encrypt 开启且 iOS 13+
+ (BOOL)shouldUseNewSecurityEncrypt;

/// 解析服务端响应：encryption=true 时解密 data；encryption=false 时直接取 data 字段。
+ (nullable id)resolvedResponseObject:(id)responseObject aesKey:(NSData *)aesKey;

@end

NS_ASSUME_NONNULL_END
