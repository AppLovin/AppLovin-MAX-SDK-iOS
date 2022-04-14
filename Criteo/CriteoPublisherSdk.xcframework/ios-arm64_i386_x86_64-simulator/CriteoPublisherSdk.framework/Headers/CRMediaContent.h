//
//  CRMediaContent.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A media content is a Native Ad sub-element that can be loaded asynchronously.
 *
 * It represents media for native product image/video or advertiser logo.
 */
@interface CRMediaContent : NSObject

@property(copy, nonatomic, readonly, nullable) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
