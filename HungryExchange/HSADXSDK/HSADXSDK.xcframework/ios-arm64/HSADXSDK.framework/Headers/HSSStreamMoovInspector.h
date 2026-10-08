//
//  HSSStreamMoovInspector.h
//  HSADXSDK
//
//  Created by 张松 on 2026/01/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSStreamMoovInspector : NSObject

@property (nonatomic, assign, readonly) BOOL moovCheckDone;
@property (nonatomic, assign, readonly) BOOL hasFoundMoov;
@property (nonatomic, assign, readonly) BOOL isBMFFDetermined;
@property (nonatomic, assign, readonly) BOOL isBMFF;
@property (nonatomic, assign, readonly) long long lastMoovOffset;
@property (nonatomic, assign, readonly) long long lastMoovSize;

- (instancetype)init;

- (void)inspectHeaderData:(NSData *)data completion:(void(^)(BOOL found))completion;

/*
- (void)tryDownloadTailWithTotalLength:(long long)totalLength
                        receivedLength:(long long)receivedLength
                            completion:(void(^)(NSData * _Nullable tailData, long long tailOffset, BOOL moovFound))completion;
 */

- (void)processTailData:(NSData *)data offset:(long long)offset completion:(void(^)(BOOL moovFound))completion;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
