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

@import Foundation;

typedef NS_ENUM(NSInteger, HSSErrorFamily) {
    kPBMErrorFamily_SetupErrors,
    //kPBMErrorFamily_TransportError,
    kPBMErrorFamily_KnownServerErrors,
    kPBMErrorFamily_UnknownServerErrors,
    kPBMErrorFamily_ResponseProcessingErrors,
    kPBMErrorFamily_IntegrationLayerErrors,
    kPBMErrorFamily_IncompatibleNativeAdMarkupAsset,
    kPBMErrorFamily_SDKMisuseErrors,
};

FOUNDATION_EXPORT NSString * const PrebidRenderingErrorDomain;

FOUNDATION_EXPORT NSInteger pbmErrorCode(HSSErrorFamily errorFamily, NSInteger errorCodeWithinFamily);
