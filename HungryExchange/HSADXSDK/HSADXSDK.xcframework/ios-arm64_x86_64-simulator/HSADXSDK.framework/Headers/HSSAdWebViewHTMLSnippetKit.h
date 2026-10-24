//
//  HSSAdWebViewHTMLSnippetKit.h
//  HSADXSDK
//
//  HTML snippet helpers for WKWebView loadHTMLString:baseURL:
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdWebViewHTMLSnippetKit : NSObject

/// loadHTMLString 的 baseURL：优先 webviewBaseURL；否则 cfg=1 时仅从首个 script src 解析 origin；再否则 nil。
+ (nullable NSURL *)baseURLForHTMLSnippet:(NSString *)htmlSnippet
                          webviewBaseURL:(nullable NSString *)webviewBaseURL;

/// viewport + 自适应样式 + htmlSnippet。
+ (NSString *)wrapHTMLSnippet:(NSString *)htmlSnippet;

@end

NS_ASSUME_NONNULL_END
