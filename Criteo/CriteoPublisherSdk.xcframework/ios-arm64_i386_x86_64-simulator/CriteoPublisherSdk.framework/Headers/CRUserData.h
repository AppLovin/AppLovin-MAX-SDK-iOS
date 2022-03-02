//
//  CRUserData.h
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
#import <CriteoPublisherSdk/CREmailHasher.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Hashed email of the user
 *
 * @discussion
 * The hashing should be the users’ email address:
 * @textblock
 * - Encoded in UTF-8
 * - Trimmed of any white space (eg: “test@criteo.com “ should become “test@criteo.com”)
 * - Converted to lower case
 * - Hashed with MD5 & output as ASCII text
 * - Hashed with SHA256 and output as ASCII text
 * @/textblock
 *
 * Example:
 * @textblock
 * - Type: String
 * - Original Email: john.doe@gmail.com
 * - MD5: e13743a7f1db7f4246badd6fd6ff54ff
 * - SHA256 of MD5: 000e3171a5110c35c69d060112bd0ba55d9631c7c2ec93f1840e4570095b263a
 * @/textblock
 *
 * @code
 * CRUserData *userData = [CRUserData userDataWithDictionary:@{
 *   CRUserDataHashedEmail: [CREmailHasher hash:@"john.doe@gmail.com"]
 * }];
 * @endcode
 * @remark You can use CREmailHasher class to hash an email accordingly to the described format
 */
FOUNDATION_EXPORT NSString *const CRUserDataHashedEmail;

/**
 * @brief A developer's own persistent unique user identifier. In case the publisher support it.
 *
 * @remark Type: String, example: "abcd12399"
 */
FOUNDATION_EXPORT NSString *const CRUserDataDevUserId;

@interface CRUserData : NSObject

+ (CRUserData *)userDataWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary;

@end

NS_ASSUME_NONNULL_END
