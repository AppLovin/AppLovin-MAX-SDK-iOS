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

@interface HSSVastTrackingEvents : NSObject

@property (nonatomic, readonly, nonnull) NSDictionary<NSString *, NSArray<NSString *> *> *trackingEvents;
@property (nonatomic, readonly, nonnull) NSArray<NSNumber *> *progressOffsets;

- (nonnull instancetype)init;

- (void)addTrackingURL:(nullable NSString *)url
                 event:(nullable NSString *)event
            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

- (nullable NSArray<NSString *> *)trackingURLsForEvent:(nonnull NSString *)event;

- (void)addTrackingEvents:(nonnull HSSVastTrackingEvents *)events;

@end
