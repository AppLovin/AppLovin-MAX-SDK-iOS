/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

@import Foundation;

#import "HSSErrorCode.h"
#import "HSSErrorType.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSVastError : NSError

- (instancetype)init: (NSString*)message NS_SWIFT_NAME(init(message:));

// MARK: - Setup errors
@property (nonatomic, copy, nullable) NSString* message;

@property (nonatomic, class, readonly) NSError *requestInProgress;

// - Transport errors
//@property (nonatomic, class, readonly) NSError *prebidDemandTimedOut;

// MARK: - Known server text errors

@property (nonatomic, class, readonly) NSError *prebidInvalidAccountId;
@property (nonatomic, class, readonly) NSError *prebidInvalidConfigId;
@property (nonatomic, class, readonly) NSError *prebidInvalidSize;
//@property (nonatomic, class, readonly) NSError *prebidDemandNoBids;

+ (NSError *)prebidServerURLInvalid:(NSString *)url;

// MARK: - Unknown server text errors

+ (NSError *)serverError:(NSString *)errorBody;

// MARK: - Response processing errors

@property (nonatomic, class, readonly) NSError *jsonDictNotFound;
@property (nonatomic, class, readonly) NSError *responseDeserializationFailed;
@property (nonatomic, class, readonly) NSError *blankResponse;

// MARK: - Integration layer errors
@property (nonatomic, class, readonly) NSError *noWinningBid;
@property (nonatomic, class, readonly) NSError *prebidNoVastTagInMediaData;

+ (HSSVastError *)errorWithDescription:(NSString *)description NS_SWIFT_NAME(error(description:));
+ (HSSVastError *)errorWithDescription:(NSString *)description statusCode:(HSSErrorCode)code NS_SWIFT_NAME(error(description:statusCode:));
+ (HSSVastError *)errorWithMessage:(NSString *)message type:(HSSErrorType)type NS_SWIFT_NAME(error(message:type:));

+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description statusCode:(HSSErrorCode)code;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error message:(NSString *)message type:(HSSErrorType)type;


@end

NS_ASSUME_NONNULL_END
