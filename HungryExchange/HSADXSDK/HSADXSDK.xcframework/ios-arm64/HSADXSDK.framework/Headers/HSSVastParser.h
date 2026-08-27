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

@class HSSVastResponse;
@class HSSVastInlineAd;
@class HSSVastWrapperAd;
@class HSSVastAbstractAd;
@class HSSVastCreativeAbstract;
@class HSSVideoVerificationParameters;
@class HSSVideoVerificationResource;

@interface HSSVastParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong, nullable) HSSVastResponse *parsedResponse;

@property (nonatomic, copy, nullable) NSString *currentElementContext;

@property (nonatomic, copy, nonnull) NSString *currentElementContent;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *currentElementAttributes;
@property (nonatomic, copy, nonnull) NSString *currentElementName;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *elementPath;

//Ad
@property (nonatomic, strong, nullable) HSSVastAbstractAd *ad;
@property (nonatomic, strong, nullable) HSSVastInlineAd *inlineAd;
@property (nonatomic, strong, nullable) HSSVastWrapperAd *wrapperAd;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *adAttributes;

@property (nonatomic, strong, nullable) HSSVideoVerificationParameters *verificationParameter;
@property (nonatomic, strong, nullable) HSSVideoVerificationResource *verificationResource;

//Creative
@property (nonatomic, strong, nullable) HSSVastCreativeAbstract *creative;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *creativeAttributes;

- (nullable HSSVastResponse *)parseAdsResponse:(nonnull NSData *)data;

- (nullable HSSVastResponse *)parseAdsStringResponse:(nonnull NSString *)string;
@end
