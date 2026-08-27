//
//  HSSOMIDSessionInteractor.h
//  HSADXSDK
//
//  Created by admin on 2025/4/2.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@class HSSCreativeItemModel;
@class HSSOMIDAdAdapter;
@class OMIDHungrystudioVASTProperties;

typedef NS_ENUM(NSUInteger, HSSOMIDFriendlyObstructionType) {
    /**
     * The friendly obstruction relates to interacting with a video (such as play/pause buttons).
     */
    HSSOMIDFriendlyObstructionMediaControls,
    /**
     * The friendly obstruction relates to closing an ad (such as a close button).
     */
    HSSOMIDFriendlyObstructionCloseAd,
    /**
     * The friendly obstruction is not visibly obstructing the ad but may seem so due to technical
     * limitations.
     */
    HSSOMIDFriendlyObstructionNotVisible,
    /**
     * The friendly obstruction is obstructing for any purpose not already described.
     */
    HSSOMIDFriendlyObstructionOther
};

/**
 * List of supported media event player states.
 */
typedef NS_ENUM(NSUInteger, HSSOMIDPlayerState) {
    /**
     * The player is collapsed in such a way that the video is hidden.
     * The video may or may not still be progressing in this state, and sound may be audible.
     * This refers specifically to the video player state on the page, and not the state of
     * the browser window.
     */
    HSSOMIDPlayerStateMinimized,
    /**
     * The player has been reduced from its original size.
     * The video is still potentially visible.
     */
    HSSOMIDPlayerStateCollapsed,
    /**
     * The player's default playback size.
     */
    HSSOMIDPlayerStateNormal,
    /**
     * The player has expanded from its original size.
     */
    HSSOMIDPlayerStateExpanded,
    /**
     * The player has entered fullscreen mode.
     */
    HSSOMIDPlayerStateFullscreen
};

/**
 * List of supported media event user interaction types.
 */
typedef NS_ENUM(NSUInteger, HSSOMIDInteractionType) {
    /**
     * The user clicked to load the ad's landing page.
     */
    HSSOMIDInteractionTypeClick,
    /**
     * The user engaged with ad content to load a separate experience.
     */
    HSSOMIDInteractionTypeAcceptInvitation
};

@interface HSSOMIDSessionInteractor : NSObject

- (instancetype)initWithAdapter:(HSSOMIDAdAdapter *)adAdapter
                         adView:(UIView *)adView
                 webViewContext:(nullable WKWebView *)webViewContext;


// Adds friendly obstruction which should then be excluded from all ad session viewability calculations.
// It also provides a purpose and detailed reason string to pass forward to the measurement vendors.
- (BOOL)addFriendlyObstruction:(UIView *)friendlyObstruction
                       purpose:(HSSOMIDFriendlyObstructionType)purpose
                detailedReason:(nullable NSString *)detailedReason
                         error:(NSError *_Nullable *_Nullable)error;

- (void)startSession;

- (void)fireAdLoaded;

- (void)fireAdLoadedWithVastProperties:(OMIDHungrystudioVASTProperties *)vastProperties;

- (void)fireImpression;

- (void)stopSession;

#pragma mark - Media Event
/**
 *  Notifies all media listeners that media content has started playing.
 *
 * @param duration The duration of the selected media (in seconds).
 * @param mediaPlayerVolume The volume from the native media player with a range between 0 and 1.
 */
- (void)startWithDuration:(CGFloat)duration
        mediaPlayerVolume:(CGFloat)mediaPlayerVolume;

/**
 *  Notifies all media listeners that media playback has reached the first quartile.
 */
- (void)firstQuartile;

/**
 *  Notifies all media listeners that media playback has reached the midpoint.
 */
- (void)midpoint;

/**
 *  Notifies all media listeners that media playback has reached the third quartile.
 */
- (void)thirdQuartile;

/**
 *  Notifies all media listeners that media playback is complete.
 */
- (void)complete;

/**
 *  Notifies all media listeners that media playback has paused after a user interaction.
 */
- (void)pause;

/**
 *  Notifies all media listeners that media playback has resumed after being paused.
 */
- (void)resume;

/**
 *  Notifies all media listeners that media playback has stopped as a user skip interaction.
 *  Once skipped, it should not be possible for the media to resume playing content.
 */
- (void)skipped;

/**
 *  Notifies all media listeners that media playback has stopped and started buffering.
 */
- (void)bufferStart;

/**
 *  Notifies all media listeners that buffering has finished and media playback has resumed.
 */
- (void)bufferFinish;

/**
 *  Notifies all media listeners that the media player volume has changed.
 *
 * @param playerVolume The volume from the native media player with a range between 0 and 1.
 */
- (void)volumeChangeTo:(CGFloat)playerVolume;

/**
 *  Notifies all media listeners that media player state has changed.
 *  See `OMIDPlayerState` for list of supported states.
 *
 * @param playerState The latest media player state.
 * @see OMIDPlayerState
 */
- (void)playerStateChangeTo:(HSSOMIDPlayerState)playerState;

/**
 *  Notifies all media listeners that the user has performed an ad interaction.
 *  See `OMIDInteractionType` for a list of supported types.
 *
 * @param interactionType The latest user integration.
 * @see OMIDInteractionType
 */
- (void)adUserInteractionWithType:(HSSOMIDInteractionType)interactionType;


@end

NS_ASSUME_NONNULL_END
