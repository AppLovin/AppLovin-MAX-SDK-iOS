//
//  HSSCryptoUtils.h
//  Example
//
//  Created by admin on 2024/12/13.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
NS_ASSUME_NONNULL_BEGIN

@interface HSSCryptoUtils : NSObject

// Create a Base-64 encoded NSString from the receiver's contents.
+ (NSString *)base64EncodedString:(NSString *)string;
+ (NSString *)base64EncodedStringWithData:(NSData *)data;

// Create an NSData from a Base-64 encoded NSString. By default, returns nil when the input is not recognized as valid Base-64.
+ (NSString *)base64DecodedString:(NSString *)base64String;
+ (NSString *)base64DecodedStringWithData:(NSData *)base64Data;

// Create a Base-64, UTF-8 encoded NSData from the receiver's contents.
+ (NSData *)base64EncodedData:(NSData *)data;
+ (NSData *)base64EncodedDataWithString:(NSString *)string;

// Create an NSData from a Base-64, UTF-8 encoded NSData. By default, returns nil when the input is not recognized as valid Base-64.
+ (NSData *)base64DecodedData:(NSData *)base64Data;
+ (NSData *)base64DecodedDataWithString:(NSString *)base64String;

// Create a 32 bit MD5 encoded NSString from the receiver's contents.
+ (NSString *)MD5EncodedString:(NSString *)string;

// Create a 16 bit MD5 encoded NSString from the receiver's contents.
+ (NSString *)bit16MD5EncodedString:(NSString *)string;

// Create a DES encoded NSString from the receiver's contents using the given key.
+ (NSString *)DESEncrypt:(NSString *)string key:(NSString *)key;

// Create a DES encoded NSString from the receiver's contents using the given key and iv.
+ (NSString *)DESEncrypt:(NSString *)string key:(NSString *)key iv:(NSString *)iv;

// Create a DES decoded NSString from the receiver's contents using the given key.
+ (NSString *)DESDecrypt:(NSString *)string key:(NSString *)key;

// Create a DES decoded NSString from the receiver's contents using the given key and iv.
+ (NSString *)DESDecrypt:(NSString *)string key:(NSString *)key iv:(NSString *)iv;

// Create an AES encoded NSString from the receiver's contents using the given key.
+ (NSString *)AESEncrypt:(NSString *)string key:(NSString *)key;

// Create an AES encoded NSString from the receiver's contents using the given key and iv.
+ (NSString *)AESEncrypt:(NSString *)string key:(NSString *)key iv:(NSString *)iv;

// Create an AES encoded data from the receiver's contents using the given key and iv.
+ (NSString *)AESEncryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv;


// Create an AES decoded NSString from the receiver's contents using the given key.
+ (NSString *)AESDecrypt:(NSString *)string key:(NSString *)key;
// Create an AES decoded NSString from the receiver's contents using the given key and iv.
+ (NSString *)AESDecrypt:(NSString *)string key:(NSString *)key iv:(NSString *)iv;

+ (NSData *)AESDecryptData:(NSData *)encryptedData key:(NSString *)key iv:(NSString *)iv;

// Create a RSA encoded NSString from the receiver's contents using the given public key.
+ (NSString *)RSAEncrypt:(NSString *)string publicKey:(NSString *)pubKey;

// Create a RSA decoded NSString from the receiver's contents using the given private key.
+ (NSString *)RSADecrypt:(NSString *)string privateKey:(NSString *)privKey;

// Create a RSA signed NSString from the receiver's contents using the given private key.
+ (NSString *)RSASign:(NSString *)string privateKey:(NSString *)privKey;

// Verify a RSA signature from the receiver's contents using the given public key.
+ (BOOL)RSAVerify:(NSString *)string signature:(NSString *)sign publicKey:(NSString *)pubKey;

// 从 PEM 公钥字符串导入 SecKeyRef（调用方负责 CFRelease）。返回值可能为 NULL。
+ (nullable SecKeyRef)getPublicKeyRef:(NSString *)key CF_RETURNS_RETAINED;

@end

NS_ASSUME_NONNULL_END
