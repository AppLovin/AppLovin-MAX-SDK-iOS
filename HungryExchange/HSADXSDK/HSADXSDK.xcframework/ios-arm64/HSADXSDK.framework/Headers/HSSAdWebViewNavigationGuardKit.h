//
//  HSSAdWebViewNavigationGuardKit.h
//  HSADXSDK
//
//  Centralizes common navigation guards (about:/javascript:) to reduce duplication.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdWebViewNavigationGuardKit : NSObject

/// Returns:
/// - YES, and sets `outPolicy`, if this URL should be immediately allowed/cancelled.
/// - NO, if caller should continue with their own logic.
///
/// Behavior is intentionally aligned with existing templates:
/// - allow about:blank / about:srcdoc
/// - cancel other about:*
/// - cancel javascript:*
+ (BOOL)shouldShortCircuitPolicyForURLString:(NSString *)urlString
                                  outPolicy:(WKNavigationActionPolicy *)outPolicy;

@end

NS_ASSUME_NONNULL_END

