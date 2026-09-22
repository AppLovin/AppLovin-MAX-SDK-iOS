//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

/**
 * Identifies which integration layer is responsible for sending certain events.
 */
typedef NS_ENUM(NSUInteger, OMIDOwner) {
    /** The integration will send the event from a JavaScript session script. */
    OMIDJavaScriptOwner = 1,
    /** The integration will send the event from the native layer. */
    OMIDNativeOwner = 2,
    /** The integration will not send the event. */
    OMIDNoneOwner = 3
};


/**
 * List of supported creative types.
 */
typedef NS_ENUM(NSUInteger, OMIDCreativeType) {
    /**
     * Creative type will be set by JavaScript session script.
     * Integrations must also pass `OMIDJavaScriptOwner` for `impressionOwner`.
     */
    OMIDCreativeTypeDefinedByJavaScript = 1,
    // Remaining values set creative type in native layer.
    /**
     * Rendered in webview, verification code can be inside creative or in metadata.
     */
    OMIDCreativeTypeHtmlDisplay = 2,
    /**
     * Rendered by native, verification code provided in metadata only.
     */
    OMIDCreativeTypeNativeDisplay = 3,
    /**
     * Rendered instream or as standalone video, verification code provided in metadata.
     */
    OMIDCreativeTypeVideo = 4,
    /**
     * Similar to video but only contains audio media.
     */
    OMIDCreativeTypeAudio = 5
};

/**
 * The criterion for an ad session's OMID impression event.
 * Declaring an impression type makes it easier to understand discrepancies between measurers
 * of the ad session, since many metrics depend on impressions.
 */
typedef NS_ENUM(NSUInteger, OMIDImpressionType) {
  /**
   * ImpressionType will be set by JavaScript session script.
   * Integrations must also pass `OMIDJavaScriptOwner` for `impressionOwner`.
   */
  OMIDImpressionTypeDefinedByJavaScript = 1,
  // Remaining values set ImpressionType in native layer.
  /**
   * The integration is not declaring the criteria for the OMID impression.
   */
  OMIDImpressionTypeUnspecified = 2,
  /**
   * The integration is using count-on-download criteria for the OMID impression.
   */
  OMIDImpressionTypeLoaded = 3,
  /**
   * The integration is using begin-to-render criteria for the OMID impression.
   */
  OMIDImpressionTypeBeginToRender = 4,
  /**
   * The integration is using one-pixel criteria (when the creative has at least 1 visible pixel on
   * screen) for the OMID impression.
   */
  OMIDImpressionTypeOnePixel = 5,
  /**
   * The integration is using viewable criteria (1 second for display, 2 seconds while playing for
   * video, and at least 50% of the creative is visible) for the OMID impression.
   */
  OMIDImpressionTypeViewable = 6,
  /**
   * The integration is using audible criteria (2 continuous second of media playback with non-zero
   * volume) for the OMID impression.
   */
  OMIDImpressionTypeAudible = 7,
  /**
   * The integration's criteria uses none of the above criteria for the OMID impression.
   */
  OMIDImpressionTypeOther = 8
};

/**
 * The ad session configuration supplies the owner for both the impression and video events.
 * The OM SDK JS service will use this information to help identify where the source of these
 * events is expected to be received.
 */
@interface OMIDHungrystudioAdSessionConfiguration : NSObject

@property OMIDCreativeType creativeType;
@property OMIDImpressionType impressionType;
@property OMIDOwner impressionOwner;
@property OMIDOwner mediaEventsOwner;
@property BOOL isolateVerificationScripts;

/**
 * Create new ad session configuration supplying the owner for both the impression and media
 * events along with the type of creative being rendered/measured.
 * The OM SDK JS service will use this information to help identify where the source of these
 * events is expected to be received.
 * @param creativeType the type of creative to be rendered in this session.
 * @param impressionType the type of impression to be triggered in this session.
 * @param impressionOwner whether the native or JavaScript layer should be responsible for supplying
 * the impression event.
 * @param mediaEventsOwner whether the native or JavaScript layer should be responsible for
 * supplying media events. This needs to be set only for non-display ad sessions and can be set to
 * `OMIDNoneOwner` for display. When the creativeType is `OMIDCreativeTypeDefinedByJavaScript` then
 * this should be set to `OMIDJavaScriptOwner`
 * @param isolateVerificationScripts determines whether verification scripts will be placed in a
 * sandboxed environment. This will not have any effect for native sessions.
 * @return A new session configuration instance.  Returns nil and sets error if OM SDK isn't active
 * or arguments are invalid.
 */
- (nullable instancetype)initWithCreativeType:(OMIDCreativeType)creativeType
                               impressionType:(OMIDImpressionType)impressionType
                              impressionOwner:(OMIDOwner)impressionOwner
                             mediaEventsOwner:(OMIDOwner)mediaEventsOwner
                   isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                        error:(NSError *_Nullable *_Nullable)error;

@end

