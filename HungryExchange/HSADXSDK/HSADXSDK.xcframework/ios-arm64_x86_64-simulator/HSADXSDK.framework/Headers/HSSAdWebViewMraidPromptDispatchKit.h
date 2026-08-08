//
//  HSSAdWebViewMraidPromptDispatchKit.h
//  HSADXSDK
//
//  Central dispatcher for MRAID-style prompt bridge requests coming via
//  `WKUIDelegate -runJavaScriptTextInputPanelWithPrompt:...`.
//
//  Goal: remove duplicated if/else ladders in templates while keeping business values in each class.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HSSAdWebViewMraidPromptProvider <NSObject>

/// getState
- (NSString *)hss_mraidPromptStateForWebView:(WKWebView *)webView;

/// isViewable
- (BOOL)hss_mraidPromptIsViewableForWebView:(WKWebView *)webView;

/// getCurrentPosition / getDefaultPosition
- (CGRect)hss_mraidPromptCurrentPositionInWindowForWebView:(WKWebView *)webView window:(UIWindow *)window;
- (CGRect)hss_mraidPromptDefaultPositionInWindowForWebView:(WKWebView *)webView window:(UIWindow *)window;

/// getMaxSize
- (CGSize)hss_mraidPromptMaxSizeForWebView:(WKWebView *)webView;

@end

typedef void (^HSSAdWebViewPromptLogBlock)(NSString *message);

@interface HSSAdWebViewMraidPromptDispatchKit : NSObject

/// Handles supported prompt events and calls completionHandler with the expected JSON string.
/// Returns YES if the prompt was recognized/handled (including invalid format / unknown method).
+ (BOOL)handlePrompt:(NSString *)prompt
              webView:(WKWebView *)webView
             provider:(id<HSSAdWebViewMraidPromptProvider>)provider
    completionHandler:(void (^)(NSString * _Nullable result))completionHandler
                  log:(nullable HSSAdWebViewPromptLogBlock)log;

@end

NS_ASSUME_NONNULL_END

