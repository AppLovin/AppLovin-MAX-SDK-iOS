//
//  HSSOMIDUtil.h
//  HSADXSDK
//
//  Created by admin on 2025/4/3.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@class OMIDHungrystudioAdSession;
@class HSSCreativeItemModel;


@interface HSSOMIDAdAdapter : NSObject

- (instancetype)initWithAdCreative:(HSSCreativeItemModel *)adCreative;

- (BOOL)supportMediaEvent;

- (BOOL)supportOMSDK;

- (NSString *)crid;

@end

@interface HSSOMIDUtil : NSObject

+ (OMIDHungrystudioAdSession *)createAdSessionWithAdAdpater:(HSSOMIDAdAdapter *)adAdpater
                                                     adView:(UIView *)adView
                                             webViewContext:(nullable WKWebView *)webViewContext;

+ (nullable NSString *)injectScriptContentIntoHTML:(nonnull NSString *)html
                                             error:(NSError *_Nullable *_Nullable)error;


@end

NS_ASSUME_NONNULL_END
