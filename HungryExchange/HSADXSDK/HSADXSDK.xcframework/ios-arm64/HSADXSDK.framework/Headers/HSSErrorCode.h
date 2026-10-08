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

/**
 * HSS VAST Error Codes (基于 VAST 4.x 标准，使用四位数避免与 HTTP 状态码冲突)
 * 
 * 分类说明：
 * - 1xxx: VAST XML 和结构错误
 * - 2xxx: 线性广告错误 (Linear Ad Errors)
 * - 3xxx: 非线性广告错误 (NonLinear Ad Errors)
 * - 4xxx: Companion 广告错误 (Companion Ad Errors)
 * - 5xxx: VAST Wrapper 相关错误
 * - 9xxx: 内部/通用错误 (Internal/General Errors)
 */
typedef NS_ENUM(NSInteger, HSSErrorCode) {
    // MARK: - VAST XML 和结构错误 (1xxx)
    
    /// VAST XML 解析错误 (对应 VAST 100)
    HSSErrorCodeXMLParsingError = 1000,
    
    /// VAST schema 验证错误 (对应 VAST 101)
    HSSErrorCodeSchemaValidationError = 1001,
    
    /// VAST 版本不支持 (对应 VAST 102)
    HSSErrorCodeVersionNotSupported = 1002,
    
    // MARK: - 线性广告错误 (2xxx - Linear Ad Errors)
    
    /// 通用线性广告错误 (对应 VAST 300)
    HSSErrorCodeGeneralLinear = 2000,
    
    /// 媒体文件未找到 / 无法请求媒体文件 (对应 VAST 301)
    HSSErrorCodeFileNotFound = 2001,
    
    /// 媒体文件请求超时 (对应 VAST 302)
    HSSErrorCodeMediaFileTimeout = 2002,
    
    /// 找不到播放器支持的媒体文件格式 (对应 VAST 303)
    HSSErrorCodeMediaFileNotSupported = 2003,
    
    /// 显示媒体文件时出现问题 (对应 VAST 405)
    HSSErrorCodeMediaFileDisplayError = 2004,
    
    // MARK: - 非线性广告错误 (3xxx - NonLinear Ad Errors)
    
    /// 通用非线性广告错误 (对应 VAST 500)
    HSSErrorCodeGeneralNonLinearAds = 3000,
    
    /// 无法显示非线性广告 (对应 VAST 501)
    HSSErrorCodeNonLinearDisplayError = 3001,
    
    /// 无法获取非线性广告资源 (对应 VAST 502)
    HSSErrorCodeNonLinearResourceFetchError = 3002,
    
    /// 找不到支持类型的非线性广告资源 (对应 VAST 503)
    HSSErrorCodeNonLinearResourceNotSupported = 3003,
    
    // MARK: - Companion 广告错误 (4xxx - Companion Ad Errors)
    
    /// 通用 Companion 广告错误 (对应 VAST 600)
    HSSErrorCodeGeneralCompanionAds = 4000,
    
    /// 无法显示 Companion 广告 (对应 VAST 601)
    HSSErrorCodeCompanionDisplayError = 4001,
    
    /// 无法获取 Companion 广告资源 (对应 VAST 602)
    HSSErrorCodeCompanionResourceFetchError = 4002,
    
    /// 找不到支持类型的 Companion 资源 (对应 VAST 603)
    HSSErrorCodeCompanionResourceNotSupported = 4003,
    
    /// 找不到支持尺寸的 Companion 广告 (对应 VAST 604)
    HSSErrorCodeCompanionDimensionNotSupported = 4004,
    
    // MARK: - VAST Wrapper 相关错误 (5xxx)
    
    /// Wrapper 层级超过限制 (对应 VAST 302 的一种情况)
    HSSErrorCodeWrapperLimitReached = 5000,
    
    /// Wrapper 无响应或超时 (对应 VAST 301)
    HSSErrorCodeWrapperNoResponse = 5001,
    
    /// 经过一个或多个 Wrapper 后仍无 VAST 响应 (对应 VAST 303)
    HSSErrorCodeNoVastResponseAfterWrapper = 5002,
    
    // MARK: - 内部/通用错误 (9xxx - Internal/General Errors)
    
    /// 通用错误 (自定义)
    HSSErrorCodeGeneral = 9000,
    
    /// 广告构建器内部错误 (对象被释放或内部状态异常)
    HSSErrorCodeAdsBuilderInternalError = 9100,
    
    /// 通用 VPAID 错误 (对应 VAST 901)
    HSSErrorCodeVPAIDError = 9901,
    
    /// 未定义错误 (对应 VAST 900) - 仅用于无法归类的错误
    HSSErrorCodeUndefined = 9900,
};

typedef NS_ENUM(NSInteger, HSSResultCode) {
    ResultCodePrebidDemandFetchSuccess = 0, /// The demand fetch request was successful.
    ResultCodePrebidServerNotSpecified = 1, /// The Prebid server was not specified in the request.
    ResultCodePrebidInvalidAccountId = 2,  /// The account ID provided is not recognized by the Prebid server.
    ResultCodePrebidInvalidConfigId = 3,   /// The config ID provided is not recognized by the Prebid server.
    ResultCodePrebidInvalidSize = 4,       /// The size requested is not recognized by the Prebid server.
    ResultCodePrebidNetworkError = 5,      /// There was a network error during the operation.
    ResultCodePrebidServerError = 6,       /// The Prebid server encountered an error while processing the request.
    ResultCodePrebidDemandNoBids = 7,      /// The Prebid server did not return any bids.
    ResultCodePrebidDemandTimedOut = 8,    /// The demand request timed out.
    ResultCodePrebidServerURLInvalid = 9,  /// The URL of the Prebid server is invalid.
    ResultCodePrebidUnknownError = 10,     /// An unknown error occurred within the Prebid SDK.
    ResultCodePrebidInvalidResponseStructure = 1000,   /// The structure of the response received is invalid.
    ResultCodePrebidInternalSDKError = 7000,           /// An internal error occurred within the SDK.
    ResultCodePrebidWrongArguments,                       /// Incorrect arguments were provided to the SDK.
    ResultCodePrebidNoVastTagInMediaData,                 /// No VAST tag was found in the media data.
    ResultCodePrebidSDKMisuse = 8000,                     /// Misuse of the SDK was detected.
    ResultCodePrebidSDKMisusePreviousFetchNotCompletedYet,/// SDK misuse due to a previous fetch operation not being completed yet.
    ResultCodePrebidInvalidRequest,                       /// The Prebid request does not contain any parameters.
};
