//
//  HSSAdWebViewPromptKit.h
//  HSADXSDK
//
//  Tiny helper to parse WKUIDelegate `runJavaScriptTextInputPanelWithPrompt:` payloads.
//  This is intentionally minimal: only extracts validated `eventName` to reduce boilerplate.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdWebViewPromptKit : NSObject

/// Returns validated `eventName` from prompt JSON, or nil if invalid.
/// `outRequestDict` is optional, and only set when parsing succeeds.
+ (nullable NSString *)eventNameFromPrompt:(NSString *)prompt
                            outRequestDict:(NSDictionary * _Nullable * _Nullable)outRequestDict;

@end

NS_ASSUME_NONNULL_END

