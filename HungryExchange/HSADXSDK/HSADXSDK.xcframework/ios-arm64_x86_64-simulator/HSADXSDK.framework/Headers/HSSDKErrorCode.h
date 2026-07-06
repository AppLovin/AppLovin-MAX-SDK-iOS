//
//  HSSErrorCode.h
//  HSADXSDK
//
//  Created by admin on 2024/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HSSErrorCodeDisableSdk = -9000000, //sdk 被禁止
    
    HSSErrorCodeAdExpired = -9001000, //广告过期
    HSSErrorCodeAdLoadFailure = -9001001, //广告加载失败
    HSSErrorCodeAdNoData = -9001002, //广告没有数据
    HSSErrorCodeAdNoFill = -9001003, //广告无填充
    HSSErrorCodePathEmpty = -9009000, //路径为空
    HSSErrorOnlyAdxBidAndBadEcpm = -9001004 // 只有adx参与竞价，但是ecpm不给力
} HSSDKErrorCode;


FOUNDATION_EXTERN NSString *const HSSErrorCodeDisableMsg;

FOUNDATION_EXTERN NSString *const HSSErrorCodeAdExpiredMsg;

FOUNDATION_EXTERN NSString *const HSSErrorCodeAdLoadFailureMsg;

FOUNDATION_EXTERN NSString *const HSSErrorCodeAdNoDataMsg;

FOUNDATION_EXTERN NSString *const HSSErrorCodeAdNoFillMsg;

FOUNDATION_EXTERN NSString *const HSSErrorCodePathEmptyMsg;

FOUNDATION_EXTERN NSString *const HSSErrorOnlyAdxBidAndBadEcpmMsg;

FOUNDATION_EXTERN NSString *const HSSADXErrorDomain;

FOUNDATION_EXTERN NSString *const HSSErrorCodeMaxBidResponseFailueMsg;

NS_ASSUME_NONNULL_END
