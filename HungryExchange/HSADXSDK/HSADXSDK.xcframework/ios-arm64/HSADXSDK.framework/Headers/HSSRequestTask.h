//
//  HSSRequestTask.h
//  HSADXSDK
//
//  Created by admin on 2024/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HSSAdxSucessBlock)(NSURLResponse * response,NSURL * url);
typedef void(^HSSAdxFailureBlock)(NSURLResponse * response,NSError * error);

@interface HSSRequestTask : NSObject

+ (instancetype)shared;

-(void)addRequest:(NSString *)reqUrl task:(NSURLSessionTask *)downTask;

-(void)addRequest:(NSString *)reqUrl success:(HSSAdxSucessBlock)success
          failure:(HSSAdxFailureBlock)failure;

-(NSArray<HSSAdxSucessBlock> *)willExeSucessRequest:(NSString *)reqUrl;

-(NSArray<HSSAdxFailureBlock> *)willExeFailureRequest:(NSString *)reqUrl;

-(BOOL)existTask:(NSString *)reqUrl;

-(void)removeHandles:(NSString *)reqUrl;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
