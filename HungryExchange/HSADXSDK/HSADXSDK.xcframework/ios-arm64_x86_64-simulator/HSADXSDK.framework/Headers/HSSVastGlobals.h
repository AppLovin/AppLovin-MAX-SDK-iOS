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

typedef NS_ENUM(NSInteger, HSSVastResourceType) {
    HSSVastResourceTypeStaticResource,
    HSSVastResourceTypeIFrameResource,
    HSSVastResourceTypeHtmlResource,
};

typedef NSString * const _Nonnull HSSVastRequiredMode NS_TYPED_ENUM;
FOUNDATION_EXPORT HSSVastRequiredMode const HSSVastRequiredModeAll;
FOUNDATION_EXPORT HSSVastRequiredMode const HSSVastRequiredModeAny;
FOUNDATION_EXPORT HSSVastRequiredMode const HSSVastRequiredModeNone;

typedef NS_ENUM(NSInteger, HSSVASTError) {
    HSSVASTErrorParsing = 100,
    HSSVASTErrorValidation,
    HSSVASTErrorUnsupportedVersion,
    HSSVASTErrorUnexpectedAdType = 200,
    HSSVASTErrorUnexpectedCreativeType,
    HSSVASTErrorUnexpectedDuration,
    HSSVASTErrorUnexpectedSize,
    HSSVASTErrorGenericWrapperError = 300,
    HSSVASTErrorWrapperTimeout,
    HSSVASTErrorWrapperLimitReached,
    HSSVASTErrorNoAdsResponse,
    HSSVASTErrorGenericLinearError = 400,
    HSSVASTErrorLinearMediaNotFound,
    HSSVASTErrorMediaFileTimeout,
    HSSVASTErrorLinearMediaUnsupported,
    HSSVASTErrorMediaFilePlayback,
    HSSVASTErrorGenericNonLinearError = 500,
    HSSVASTErrorNonLinearDimensions,
    HSSVASTErrorNonLinearMediaNotFound,
    HSSVASTErrorNonLinearResourceUnsupported,
    HSSVASTErrorGenericCompanionError = 600,
    HSSVASTErrorCompanionDimensions,
    HSSVASTErrorRequiredCompanionUnavailable,
    HSSVASTErrorCompanionMediaNotFound,
    HSSVASTErrorCompanionResourceUnsupported,
    HSSVASTErrorUndefinedError = 900
};
