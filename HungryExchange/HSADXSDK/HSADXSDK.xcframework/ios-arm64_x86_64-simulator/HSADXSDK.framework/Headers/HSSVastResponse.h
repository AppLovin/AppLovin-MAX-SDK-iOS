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

//This class is analogous to the <VAST> tag at the root of a Vast XML doc.

#import <Foundation/Foundation.h>

@class HSSVastAbstractAd;

@interface HSSVastResponse : NSObject

//TODO: Refactor HSSVastResponse.nextResponse and HSSVastWrapper.vastResponse together.

@property (nonatomic, strong, nullable) HSSVastResponse *nextResponse;
@property (nonatomic, weak, nullable) HSSVastResponse *parentResponse   NS_SWIFT_NAME(parentResponse);
@property (nonatomic, copy, nullable) NSString *noAdsResponseURI;
@property (nonatomic, strong, nonnull) NSMutableArray<HSSVastAbstractAd *> *vastAbstractAds; // TODO: should be readonly
@property (nonatomic, copy, nullable) NSString *version;

- (nullable NSArray<HSSVastAbstractAd *> *)flattenResponseAndReturnError:(NSError * __nullable * __null_unspecified)error;

@end
