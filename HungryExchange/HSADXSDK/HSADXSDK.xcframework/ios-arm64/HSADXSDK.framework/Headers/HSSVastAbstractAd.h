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
@class HSSVastCreativeAbstract;

//In the VAST XML Structure, <VAST> nodes have 1 or more <Ad> children.
//Each <Ad> has either a <Wrapper> or <InLine> child.
//Wrappers essentially contain another <VAST> tag that can have <Ad>, <Wrapper> and <Inline> children, but all <Wrapper> tags
//Ultimately terminate in <Inline> leaves.

//To represent this, we have this class implemented as abstract and PBMVastWrapperAd and PBMVastInlineAd are concrete.

@interface HSSVastAbstractAd : NSObject

@property (nonatomic, weak, nullable) HSSVastResponse *ownerResponse;
@property (nonatomic, copy, nonnull) NSString *identifier;
@property (nonatomic, assign) NSInteger sequence;

@property (nonatomic, copy, nonnull) NSString *adSystem;
@property (nonatomic, copy, nonnull) NSString *adSystemVersion;

@property (nonatomic, copy, nonnull) NSString *extensionPixel;

@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *impressionURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *errorURIs;
@property (nonatomic, strong, nonnull) NSMutableArray<HSSVastCreativeAbstract *> *creatives;

@end
