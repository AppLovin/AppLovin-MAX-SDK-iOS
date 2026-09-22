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
#import "HSSVastTrackingEvents.h"
#import "HSSVastResourceContainerProtocol.h"

@interface HSSVastCreativeCompanionAdsCompanion : NSObject <HSSVastResourceContainerProtocol>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong, nonnull) HSSVastTrackingEvents *trackingEvents;

@property (nonatomic, assign) NSInteger assetWidth;
@property (nonatomic, assign) NSInteger assetHeight;
@property (nonatomic, copy, nullable) NSString *companionIdentifier;
@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, copy, nullable) NSString *adParameters;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

// PBMVastResourceContainer
@property (nonatomic, assign) HSSVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

@end
