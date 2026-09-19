//
//  HSSAdWebViewMessageDispatchKit.h
//  HSADXSDK
//
//  Centralizes WKScriptMessage parsing/dispatching to reduce duplication across templates.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HSSAdWebViewOpenMessageHandler)(NSString * _Nullable urlString,
                                              NSString * _Nullable target,
                                              WKWebView *webView,
                                              NSDictionary *payload);

typedef void (^HSSAdWebViewEventMessageHandler)(NSString *eventName,
                                               WKWebView *webView,
                                               NSDictionary *payload);

@interface HSSAdWebViewMessageDispatchKit : NSObject

/// Parses `WKScriptMessage` payload and dispatches to `openHandler` / `eventHandler`.
/// Expected payload format:
/// - message.body is NSDictionary
/// - payload["action"] == "open" or "event"
/// - for "open": payload["url"], payload["target"]
/// - for "event": payload["eventName"]
///
/// Returns YES if message is for `handlerName` and was parsed & dispatched.
+ (BOOL)dispatchScriptMessage:(WKScriptMessage *)message
                  handlerName:(NSString *)handlerName
                  openHandler:(nullable HSSAdWebViewOpenMessageHandler)openHandler
                 eventHandler:(nullable HSSAdWebViewEventMessageHandler)eventHandler;

/// Emits `mraid.emit('error', ['not support', feature])` for unsupported MRAID APIs.
/// Returns YES if the feature was recognized as a common unsupported event and an error was emitted.
+ (BOOL)handleCommonUnsupportedMraidEventName:(NSString *)eventName
                                      webView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END

