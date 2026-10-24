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

#import <Foundation/Foundation.h>

@class HSSVastParser;
@class HSSVastResponse;
@class Prebid;
@class HSSVastAbstractAd;

@protocol PrebidServerConnectionProtocol;

//TODO: alter PrebidServerConnection to deliver NSData.
//Otherwise, done.

typedef void(^HSSVastAdsBuilderCompletionBlock)(NSArray<HSSVastAbstractAd *> * _Nullable, NSError * _Nullable);

@interface HSSVastAdsBuilder : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithConnection:(nullable id<PrebidServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

- (void)buildAds:(nonnull NSData *)data completion:(nonnull HSSVastAdsBuilderCompletionBlock)completionBlock;

- (BOOL)checkHasNoAdsAndFireURIs:(nonnull HSSVastResponse *)vastResponse  NS_SWIFT_NAME(checkHasNoAdsAndFireURIs(vastResponse:));

@end
