//
// Created by Daria Sukhonosova on 19/04/16.
//

#import <UIKit/UIKit.h>

#if !(TARGET_OS_TV)
#import <WebKit/WebKit.h>
#endif

#import "OMIDPartner.h"
#import "OMIDVerificationScriptResource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Provides the ad session with details of the partner and whether to an HTML,
 *  JavaScript, or native session.
 */
@interface OMIDHungrystudioAdSessionContext : NSObject

- (null_unspecified instancetype)init NS_UNAVAILABLE;

#if !(TARGET_OS_TV)

/**
 * Initializes a new ad session context providing reference to partner and web view where
 * the OM SDK JavaScript service has been injected.
 *
 * Calling this method will set the ad session type to `html`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OM SDK has not been
 * activated (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The WKWebView responsible for serving the ad content. The receiver holds a weak reference only.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new HTML context instance. Returns nil if OM SDK has not been activated or if
 *   any of the parameters are nil.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(OMIDHungrystudioPartner *)partner
                                 webView:(WKWebView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;
#endif

/**
 * Initializes a new ad session context providing reference to partner and a list of
 * script resources which should be managed by OMID.
 *
 * Calling this method will set the ad session type to `native`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated
 * (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param resources The array of all verification providers who expect to receive OMID
 *   event data. Must contain at least one verification script. The receiver creates a
 *   deep copy of the array.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new native context instance. Returns nil if OMID has not been activated or if any of the parameters are invalid.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(OMIDHungrystudioPartner *)partner
                                  script:(NSString *)script
                               resources:(NSArray<OMIDHungrystudioVerificationScriptResource *> *)resources
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

#if !(TARGET_OS_TV)
/**
 * Initializes a new ad session context providing reference to partner and web view where
 * OM SDK JavaScript service has been injected.
 *
 * Calling this method will set the ad session type to `javascript`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated
 * (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The WKWebView responsible for serving the ad content. The receiver holds a weak reference only.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new JavaScript context instance. Returns nil if OM SDK has not been
 *   activated or if any of the parameters are invalid.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(OMIDHungrystudioPartner *)partner
                       javaScriptWebView:(WKWebView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;
#endif

@end

NS_ASSUME_NONNULL_END
