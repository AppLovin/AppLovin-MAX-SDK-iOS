#include <TargetConditionals.h>
#if !(TARGET_OS_TV)

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OMIDFriendlyObstructionType.h"
#import "OMIDPartner.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Service supporting ad sessions managed (started/finished) via JavaScript Session Client APIs
 * by providing native-layer measurement signals.
 * If the JS Session Client is running in a web view, an instance of this service must be
 * initialized with the web view before starting or finishing ad sessions using JS APIs.
 * Only one instance of this service may be initialized at a time for a given web view; to reuse a
 * web view the current instance must be torn down (see `tearDownWithCompletion`).
 */
@interface OMIDHungrystudioJavaScriptSessionService : NSObject <WKScriptMessageHandler>

/**
 * Initializes an instance of the service.
 *
 * @param partner Details of the integration partner responsible for ad sessions.
 * @param webView The web view responsible for starting/finishing ad sessions via the JS Session
 * Client.
 * @param isHTMLAdView Whether the ad is rendered in HTML inside of the provided web view.
 * If true, all ad sessions will be of type "html" and calling `setAdView` is
 * not required.
 * If false, all ad sessions will be of type "javascript" and `setAdView` must
 * be called after initialization.
 */
- (nullable instancetype)initWithPartner:(OMIDHungrystudioPartner *)partner
                                 webView:(WKWebView *)webView
                            isHTMLAdView:(BOOL)isHTMLAdView
                                   error:(NSError *_Nullable *_Nullable)error;

/**
 * Tears down this instance of the service.
 * Calling this method will cause OM SDK to begin a teardown process including finishing all currently
 * active ad sessions measured by this service instance and tearing down communication with the OM
 * SDK's JavaScript layer running in the web view.
 * This may require up to one second, for example in order to allow verification scripts time to process
 * the `sessionFinish` event.
 * Once this process has completed, the web view may be torn down or reused for another instance of
 * the service without any adverse effects. If there is no need to tear down or reuse the web view, this
 * method is not required.
 * @param completionBlock Invoked by OM SDK after the teardown process has completed,
 * or one second, whichever comes sooner.
 */
- (void)tearDownWithCompletion:(void (^)(BOOL success, NSError *_Nullable error))completionBlock;

/**
 * The native view containing the ad.
 * This property is readonly and must be set using `setAdView`.
 * If `isHTMLAdView` was passed as true in `initWithPartner`, this will equal
 * the web view by default.
 */
@property(readonly, nonatomic, weak) UIView *adView;

/**
 * Sets the native view that contains the ad and is used for viewability tracking.
 * If `isHTMLAdView` was passed as true in `initWithPartner`, this method is
 * not required since the ad view will be set to the web view by default.
 * @param adView The native view.
 * @return Whether the ad view was successfully set.
 */
- (BOOL)setAdView:(nullable UIView *)adView
            error:(NSError **)error;

/**
 * Adds a friendly obstruction which should then be excluded from all ad session viewability
 * calculations. While this instance of OMIDJavaScriptSessionService is running, this friendly
 * obstruction will be added to each ad session started by the integrator via the JS Session Client
 * until the obstruction is removed by calling `removeFriendlyObstruction` or
 * `removeAllFriendlyObstructions`.
 *
 * @param friendlyObstruction The view to be excluded from all ad session viewability calculations.
 * @param purpose The purpose of why this obstruction was necessary.
 * @param detailedReason An explanation for why this obstruction is part of the ad experience if not
 * already obvious from the purpose. Can be nil. If not nil, must be 50 characters or less and only
 * contain characters `A-z`, `0-9`, or spaces.
 * @return Whether this friendly obstruction was successfully added. If the friendlyObstruction has
 * already been added for this session, this method will return NO with no associated error object.
 * However, if one or more arguments are against requirements, it will return NO with an error
 * object assigned.
 */
- (BOOL)addFriendlyObstruction:(UIView *)friendlyObstruction
                       purpose:(OMIDFriendlyObstructionType)purpose
                detailedReason:(nullable NSString *)detailedReason
                         error:(NSError *_Nullable *_Nullable)error;

/**
 * Removes a registered friendly obstruction from any currently running and future ad sessions
 * measured by this instance of OMIDJavaScriptSessionService.
 */
- (void)removeFriendlyObstruction:(UIView *)friendlyObstruction;

/**
 * Removes all registered friendly obstructions from any currently running and future ad sessions
 * measured by this instance of OMIDJavaScriptSessionService.
 */
- (void)removeAllFriendlyObstructions;

@end

NS_ASSUME_NONNULL_END

#endif
