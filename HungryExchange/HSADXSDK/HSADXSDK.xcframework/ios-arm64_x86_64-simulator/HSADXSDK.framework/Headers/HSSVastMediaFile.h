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

@interface HSSVastMediaFile : NSObject

@property (nonatomic, assign) BOOL streamingDeliver;
@property (nonatomic, copy, nonnull) NSString *type;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy, nonnull) NSString *mediaURI;

@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *codec;
@property (nonatomic, copy, nullable) NSString *deivery;
@property (nonatomic, copy, nullable) NSNumber *bitrate;
@property (nonatomic, copy, nullable) NSNumber *minBitrate;
@property (nonatomic, copy, nullable) NSNumber *maxBitrate;
@property (nonatomic, copy, nullable) NSNumber *scalable;
@property (nonatomic, copy, nullable) NSNumber *maintainAspectRatio;
@property (nonatomic, copy, nullable) NSString *apiFramework;

- (nonnull instancetype)init;

- (void)setDeliver:(nullable NSString *) deliveryMode;

@end
