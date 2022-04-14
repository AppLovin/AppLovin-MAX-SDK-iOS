//
//  CRContextData.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A single URL of the content, for buy-side contextualization or review.
 *
 * @remark Type: String, like <em>https://www.criteo.com</em>
 */
FOUNDATION_EXPORT NSString *const CRContextDataContentUrl;

@interface CRContextData : NSObject

+ (CRContextData *)contextDataWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end

NS_ASSUME_NONNULL_END
