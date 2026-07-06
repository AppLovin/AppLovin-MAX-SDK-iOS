//
//  HSSAdDirectBidShowGate.h
//  HSADXSDK
//
//  插屏 / 激励共用的「直连且仅 ADX 出价」展示前校验（与 ``HSSInnerSettings.adShowConfig`` 联动）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSBidResultModel;

@interface HSSAdDirectBidShowGate : NSObject

/// 返回 YES 表示允许展示；NO 表示应拦截（如 ``HSSErrorOnlyAdxBidAndBadEcpm``）。
+ (BOOL)enableShowWithBidResult:(nullable HSSBidResultModel *)bidResult
                      extraInfo:(nullable NSDictionary *)extraInfo
                   currentEcpm:(double)currentEcpm;

@end

NS_ASSUME_NONNULL_END
