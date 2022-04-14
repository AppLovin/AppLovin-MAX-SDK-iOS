//
//  CRNativeAd.h
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

@class CRMediaContent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Model gathering the assets of an Advance Native Ad.
 */
@interface CRNativeAd : NSObject

/** The headline (like the name of the advertised product). */
@property(nonatomic, copy, readonly, nullable) NSString *title;
/** The description of the product. */
@property(nonatomic, copy, readonly, nullable) NSString *body;
/** The price of the product. */
@property(nonatomic, copy, readonly, nullable) NSString *price;
/** Text that encourages user to take some action with the ad. For example "Buy" or "Install". */
@property(nonatomic, copy, readonly, nullable) NSString *callToAction;
/** The image that represents the product. */
@property(nonatomic, copy, readonly) CRMediaContent *productMedia;
/** The description of the company that advertises the product. */
@property(nonatomic, copy, readonly, nullable) NSString *advertiserDescription;
/** The domain name of the company that advertises the product. */
@property(nonatomic, copy, readonly) NSString *advertiserDomain;
/** The logo of the company that advertises the product. */
@property(nonatomic, copy, readonly, nullable) CRMediaContent *advertiserLogoMedia;
/** The legal text related to ad. */
@property(nonatomic, copy, readonly, nullable) NSString *legalText;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
