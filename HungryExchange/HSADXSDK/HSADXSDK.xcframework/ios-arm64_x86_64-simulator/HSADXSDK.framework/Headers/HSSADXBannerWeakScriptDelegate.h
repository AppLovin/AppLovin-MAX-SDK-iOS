//
//  HSSADXBannerWeakScriptDelegate.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/4/24.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// 创建中间代理对象
@interface HSSADXBannerWeakScriptDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
