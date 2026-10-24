//
//  HSSAdWebViewBridgeKit.h
//  HSADXSDK
//
//  Centralizes WKWebView configuration, JavaScript injection (window.open override, dist_mraid.js),
//  and message handler registration to reduce duplication across templates.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HSSWKWebViewConfigurationMutator)(WKWebViewConfiguration *config);

@interface HSSAdWebViewBridgeKit : NSObject

/// Simplified factory: internally reads `[HSSInnerSettings shared].mraid_main_frame_only`
/// and uses it for both `windowOpenForMainFrameOnly` and `mraidForMainFrameOnly`.
+ (WKWebViewConfiguration *)configurationWithMessageHandlerDelegate:(id<WKScriptMessageHandler>)delegate
                                                       handlerName:(NSString *)handlerName
                                                 injectWindowOpenJS:(BOOL)injectWindowOpenJS
                                                      injectMRAIDJS:(BOOL)injectMRAIDJS
                                                           mutator:(nullable HSSWKWebViewConfigurationMutator)mutator;

/// Playable factory (behavior-preserving with current Rewarded/Interstitial playable WebViews):
/// - registers `handlerName` as script message handler (strongly, same as direct WebKit API)
/// - injects bundled `mraid.js` at DocumentStart, forMainFrameOnly:YES
/// - configures autoplay/inline playback (mediaTypesRequiringUserActionForPlayback = None, allowsInlineMediaPlayback = YES)
+ (WKWebViewConfiguration *)playableConfigurationWithMessageHandler:(id<WKScriptMessageHandler>)handler
                                                       handlerName:(NSString *)handlerName
                                                          mutator:(nullable HSSWKWebViewConfigurationMutator)mutator;

/// Installs bridge pieces onto an existing configuration.
/// Internally reads `[HSSInnerSettings shared].mraid_main_frame_only` and uses it for:
/// - `window.open` override injection forMainFrameOnly
/// - `dist_mraid.js` injection forMainFrameOnly
+ (void)installOnConfiguration:(WKWebViewConfiguration *)config
        messageHandlerDelegate:(id<WKScriptMessageHandler>)delegate
                   handlerName:(NSString *)handlerName
            injectWindowOpenJS:(BOOL)injectWindowOpenJS
                 injectMRAIDJS:(BOOL)injectMRAIDJS;

@end

NS_ASSUME_NONNULL_END

