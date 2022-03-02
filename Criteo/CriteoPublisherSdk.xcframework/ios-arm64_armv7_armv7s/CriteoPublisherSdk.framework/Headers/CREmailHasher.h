//
//  CREmailHasher.h
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

@interface CREmailHasher : NSObject

/**
 * @brief Helper function to hash emails for `CRUserDataHashedEmail`
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
 */
+ (NSString *)hash:(NSString *)email;

@end

NS_ASSUME_NONNULL_END
