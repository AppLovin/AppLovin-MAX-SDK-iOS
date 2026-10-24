//
//  HSSNetEncrypt.h
//  HSADXSDK
//
//  Created by admin on 2024/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSNetEncrypt : NSObject

/**
 @param params 需要加密的参数
 @return 加密后结果, 包含 "key" : 加密密钥 , "data" : 加密数据 , 
 */
+(NSDictionary *)encrypt:(NSString *)params;

/**
 解密数据
 */
+(id)decrypt:(NSString *)encryptStr key:(NSString *)encryptKey;

/**
 RSA 公钥（PEM 格式，BEGIN PUBLIC KEY）。
 暴露给安全请求模块用于加密 AES 密钥。
 */
+ (NSString *)rsaPublicKey;
@end

NS_ASSUME_NONNULL_END
