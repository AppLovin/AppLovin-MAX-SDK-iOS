//
//  HSSAdWebViewJavaScriptKit.h
//  HSADXSDK
//
//  Centralizes common JS emission patterns (mraid.emit + evaluateJavaScript) to reduce duplication.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdWebViewJavaScriptKit : NSObject

/// Generic evaluation helper with unified error logging.
+ (void)evaluateJavaScript:(NSString *)javaScript
                   webView:(WKWebView *)webView
                       tag:(NSString *)tag;

/// mraid.emit('audioVolumeChange', <vol>)
+ (void)emitAudioVolumeChange:(NSInteger)volume
                      webView:(WKWebView *)webView
                          tag:(NSString *)tag;

/// mraid.emit('stateChange', '<state>')
+ (void)emitStateChange:(NSString *)state
                webView:(WKWebView *)webView
                    tag:(NSString *)tag;

/// mraid.emit('ready')
+ (void)emitReady:(WKWebView *)webView
              tag:(NSString *)tag;

/// Behavior-preserving helper for current templates:
/// mraid.emit('viewableChange', 'true'/'false')
+ (void)emitViewableChangeAsString:(BOOL)viewable
                   webView:(WKWebView *)webView
                       tag:(NSString *)tag;

/// Behavior-preserving helper for current templates:
/// mraid.emit('exposureChange', <jsonArrayExpression>)
+ (void)emitExposureChangeWithJSONArrayExpression:(NSString *)jsonArrayExpression
                   webView:(WKWebView *)webView
                       tag:(NSString *)tag;

/// mraid.emit('error', ['not support', '<feature>'])
+ (void)emitNotSupportErrorForFeature:(NSString *)feature
                              webView:(WKWebView *)webView
                                  tag:(NSString *)tag;

/// Serialize object to JSON string. Returns @"{}" on failure.
+ (NSString *)serializeToJSON:(id)object;

@end

NS_ASSUME_NONNULL_END

