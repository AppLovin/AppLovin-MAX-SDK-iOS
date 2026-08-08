//
//  HSSNetworking.h
//  Pods-Example
//
//  Created by admin on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSNetworkConstant.h>
#import <HSADXSDK/HSSError.h>

typedef NS_ENUM(NSUInteger, HSSHTTPResponseSerializerStyle) {
    HSSHTTPResponseSerializerDefaultStyle = 0,
    HSSHTTPResponseSerializerJsontStyle = 1,
    HSSHTTPResponseSerializerXMLStyle = 2,
};
NS_ASSUME_NONNULL_BEGIN

typedef void(^HSSNetCompletionHandler)(NSURLRequest *request,NSURLResponse * _Nullable response, id _Nullable responseObject,HSSError * _Nullable error);

@interface HSSAdNetworking : NSObject

+ (NSURLSessionDataTask *_Nullable)dataTaskWithPath:(NSString *_Nonnull)path
                                             method:(HSSRequestMode)method
                                 resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                         parameters:(NSDictionary *_Nullable)parameters
                                  completionHandler:(HSSNetCompletionHandler)completionHandler;

+ (NSURLSessionDataTask *_Nullable)dataTaskWithPath:(NSString *_Nonnull)path
                                             method:(HSSRequestMode)method
                                 resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                             header:(NSDictionary *_Nullable)header
                                         parameters:(NSDictionary *_Nullable)parameters
                                  completionHandler:(HSSNetCompletionHandler)completionHandler;

/**
 使用加密接口请求数据
 */
+ (NSURLSessionDataTask *_Nullable)dataTaskWithEncryptPath:(NSString *_Nonnull)path
                                             method:(HSSRequestMode)method
                                 resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                             header:(NSDictionary *_Nullable)header
                                         parameters:(NSDictionary *_Nullable)parameters
                                  completionHandler:(HSSNetCompletionHandler)completionHandler;

// fromPublic: 宿主app通过adx进行请求
+ (NSURLSessionDataTask *_Nullable)dataTaskWithEncryptPath:(NSString *_Nonnull)path
                                             method:(HSSRequestMode)method
                                 resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                             header:(NSDictionary *_Nullable)header
                                         parameters:(NSDictionary *_Nullable)parameters
                                         fromPublic:(BOOL)fromPublic
                                  completionHandler:(HSSNetCompletionHandler)completionHandler;

/**
 通用请求，内部不携带任何通用 params and header
 */
+ (NSURLSessionDataTask *_Nullable)dataTaskUniversalWithPath:(NSString *_Nonnull)path
                                             method:(HSSRequestMode)method
                                 resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                             header:(NSDictionary *_Nullable)header
                                         parameters:(NSDictionary *_Nullable)parameters
                                  completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, id _Nullable responseObject,HSSError * _Nullable error))completionHandler;


/**
 根据URL下载文件

 @param URL 下载地址
 @param filePath 本地保存路径 建议 [NSURL fileURLWithPath:@"xxxxx"];
 @param progressBlock 进度0.0-1.0
 @param completionHandler 完成回调
 @return 下载对象
 */
+ (NSURLSessionDownloadTask *_Nullable)downloadTaskWithURL:(NSURL *_Nonnull)URL
                                                  filePath:(NSURL *_Nonnull)filePath
                                             progressBlock:(void (^_Nullable)(CGFloat progress))progressBlock
                                         completionHandler:(void (^_Nullable)(NSURLResponse *_Nullable response,
                                                                              NSURL * _Nullable filePath,
                                                                              NSError * _Nullable error))completionHandler;
/**
 通用请求，内部不携带任何通用 params and header
 */
+ (NSURLSessionDataTask *_Nullable)dataTaskWithRequest:(NSMutableURLRequest *_Nonnull)request
                                    resSerializerStyle:(HSSHTTPResponseSerializerStyle)style
                                     completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, id _Nullable responseObject,HSSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
