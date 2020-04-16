//
//  ALCarouselMediaView.m
//  sdk
//
//  Created by Thomas So on 4/20/15.
//
//

@import AppLovinSDK;
#import "ALCarouselMediaView.h"
#import "ALCarouselCardState.h"
#import "ALCarouselReplayOverlayView.h"
#import "ALCarouselCardView.h"
#import "ALCarouselViewSettings.h"
#import "ALDebugLog.h"
#import "ALNativeAdVideoPlayer.h"
#import "ALNativeAdVideoView.h"

@interface ALCarouselMediaView()

@property (weak,   nonatomic) ALSdk *sdk;

@property (strong, nonatomic) ALCarouselCardView *cardView;
@property (strong, nonatomic) ALCarouselCardState *cardState;
@property (strong, nonatomic) ALNativeAd *ad;

@property (strong, nonatomic) UIImageView *adImageView;

@property (strong, nonatomic) ALNativeAdVideoPlayer *videoPlayer;
@property (weak,   nonatomic) ALNativeAdVideoView *videoView;
@property (strong, nonatomic) UIButton *muteButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) ALCarouselReplayOverlayView *replayOverlayView;

@end

@implementation ALCarouselMediaView
static NSString *const TAG = @"ALCarouselMediaView";

#pragma mark - Initialization Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.sdk = [ALSdk shared];
        [self setup];
    }
    return self;
}

- (instancetype)initWithSdk:(ALSdk *)sdk parentView:(ALCarouselCardView *)parentView;
{
    self = [super init];
    if ( self )
    {
        self.sdk = sdk;
        self.cardView = parentView;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = kVideoViewBackgroundColor;
    
    self.adImageView = [[UIImageView alloc] init];
    self.adImageView.userInteractionEnabled = NO;
    self.adImageView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *adImageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapAdImage:)];
    [self.adImageView addGestureRecognizer: adImageTapGesture];
    
    if ( self.replayOverlayView )
    {
        [self.replayOverlayView removeFromSuperview];
    }
    
    self.replayOverlayView = [[ALCarouselReplayOverlayView alloc] initWithParentView: self];
    self.replayOverlayView.alpha = 0.0f;
    self.replayOverlayView.userInteractionEnabled = YES;
    [self.replayOverlayView.replayIconButton    addTarget: self action: @selector(didTapReplayButton:)    forControlEvents: UIControlEventTouchUpInside];
    [self.replayOverlayView.replayButton        addTarget: self action: @selector(didTapReplayButton:)    forControlEvents: UIControlEventTouchUpInside];
    [self.replayOverlayView.learnMoreIconButton addTarget: self action: @selector(didTapLearnMoreButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.replayOverlayView.learnMoreButton     addTarget: self action: @selector(didTapLearnMoreButton:) forControlEvents: UIControlEventTouchUpInside];
    
    [self addSubview: self.adImageView];
    [self addSubview: self.replayOverlayView];
}

#pragma mark - App Notifications

- (void)appPaused:(NSNotification *)notification
{
    [self deactivateIfNeeded];
}

- (void)appResumed:(NSNotification *)notification
{
    [self reactivateIfNeeded];
}

#pragma mark - View Management

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow: newWindow];
    
    // Will be moved into a window
    if ( newWindow )
    {
        [self reactivateIfNeeded];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appPaused:)  name: UIApplicationDidEnterBackgroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appResumed:) name: UIApplicationDidBecomeActiveNotification    object: nil];
    }
    // Will be removed from window
    else
    {
        [self deactivateIfNeeded];
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.videoView.frame           = self.bounds;
    
    const CGFloat muteButtonWidth  = kMuteWidth + kMuteButtonPadding;
    const CGFloat muteButtonHeight = kMuteHeight + kMuteButtonPadding;
    
    CGRect muteFrame      = CGRectZero;
    muteFrame.origin.x    = kMuteButtonMargin;
    muteFrame.origin.y    = CGRectGetMaxY(self.videoView.frame) - muteButtonHeight - kMuteButtonMargin;
    muteFrame.size.width  = muteButtonWidth;
    muteFrame.size.height = muteButtonHeight;
    self.muteButton.frame = muteFrame;
    self.muteButton.imageEdgeInsets = UIEdgeInsetsMake(kMuteButtonPadding, 0.0f, 0.0f, kMuteButtonPadding);
    
    self.playButton.frame  = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), kPlayReplayWidth, kPlayReplayHeight);
    self.playButton.center = self.videoView.center;
    
    self.replayOverlayView.frame = self.bounds;
    self.adImageView.frame = self.cardState.screenshot ? self.cardState.videoRect : self.bounds;
}

// Entry points
- (void)renderViewForNativeAd:(ALNativeAd *)ad
{
    ALCarouselCardState *cardState = [ALCarouselCardState cardStateForSingleCard];
    [self renderViewForNativeAd: ad cardState: cardState];
}

- (void)renderViewForNativeAd:(ALNativeAd *)ad cardState:(ALCarouselCardState *)cardState
{
    if ( ad )
    {
        self.ad = ad;
        self.cardState = cardState;
        [self createVideoPlayerIfNeeded];
        [self refresh];
    }
    else
    {
        [self clearView];
    }
}

- (void)refresh
{
    const ALNativeAd *ad = self.ad;
    if ( ad )
    {
        // If we get to this point, ad image is pre-cached
        ALLog(@"Begin refresh media view for slot ID: %@ %@", ad.adIdNumber, ad.title);
        
        self.adImageView.userInteractionEnabled = YES;
        
        // Populate ad image behind replay overlay
        if ( self.cardState.screenshot && !CGRectIsEmpty(self.cardState.videoRect) )
        {
            // If this card has a video screenshot rendered, set that as the ad image
            self.adImageView.image = self.cardState.screenshot;
            self.adImageView.frame = self.cardState.videoRect;
        }
        else
        {
            // Else, just set the ad image to the default one
            self.adImageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: ad.imageURL]];
            self.adImageView.frame = self.bounds;
        }
        
        // If the replay overlay is supposed to be visible, show it and hide the video controls
        if ( self.cardState.replayOverlayVisible )
        {
            self.replayOverlayView.alpha = 1.0f;
            self.playButton.alpha        = 0.0f;
            self.muteButton.alpha        = 0.0f;
        }
        // Else, hide the replay overlay. Visibility of video controls will be determined if autoplay is on/off
        else
        {
            self.replayOverlayView.alpha = 0.0f;
        }
        
        // If this is the middle/single card, we give it special treatment
        if ( self.cardState.currentlyActive )
        {
            // If the video is pre-cached or we should stream
            if ( [ad isVideoPrecached] )
            {
                // Autoplay if required (if config says so, and replay overlay is not currently showing)
                [self autoplayIfRequired];
            }
            // Video is still pre-caching. Will show on top of ad image when pre-cached from carousel view
            else
            {
                ALLog(@"Video still waiting to be pre-cached for slot (%@)...", ad.adIdNumber);
            }
        }
        else
        {
            // No special treatment for non-middle cards
        }
    }
    else
    {
        ALLog(@"Begin refresh for nil slot. Clearing view...");
        [self clearView];
    }
}

#pragma mark - Video Action Methods

- (void)autoplayIfRequired
{
    self.adImageView.userInteractionEnabled = NO;
    
    // Update the mute button regardless if we're autoplaying since we'll have to animate it regardless
    [self updateMuteState];
    
    // If the video is not waiting to be replayed
    if ( !self.cardState.replayOverlayVisible )
    {
        // If configuration says we should autoplay
        if ( kIsAutoplay )
        {
            [self playVideoIfInactive];
        }
        else
        {
            // If we're not going to autoplay the video, animate in the video controls
            [UIView animateWithDuration: 0.5f animations:^{
                self.playButton.alpha = 1.0f;
            }];
        }
    }
}

- (void)playVideoIfInactive
{
    if ( [self isCurrentlyPlayingVideo] )
    {
        ALLog(@"Attempting to play a video that's already playing");
    }
    else
    {
        ALLog(@"Video play requested...");
        
        self.videoView.playerLayer.backgroundColor = kVideoViewBackgroundWhilePlayingColor.CGColor;
        self.videoView.backgroundColor = kVideoViewBackgroundWhilePlayingColor;

        // Prepare the view to play video
        [UIView animateWithDuration: 1.0f animations:^{
            
            self.muteButton.alpha  = 1.0f;
            self.playButton.alpha  = 0.0f;
            
            // Crossfade the video in and the ad image out then autoplay the video if needed
            self.adImageView.alpha = 0.0f;
            self.videoView.alpha   = 1.0f;
        }];
        
        self.adImageView.userInteractionEnabled = NO;
        
        // When replaying a video we do not fade out the replay overlay
        self.replayOverlayView.alpha        = 0.0f;
        self.cardState.replayOverlayVisible = NO;
        
        // Attach new observer to get notified when video ends
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(playerItemDidReachEnd:)
                                                     name: AVPlayerItemDidPlayToEndTimeNotification
                                                   object: self.videoView.player.currentItem];
        
        // Prepare the video
        self.videoPlayer.mediaSource = self.ad.videoURL;
        [self seekToPosition: self.cardState.lastMediaPlayerPosition];
        self.cardState.videoStarted = YES;
        [self.videoPlayer playVideo];
        
        
        // Track the video start if we didn't track it yet
        if ( !self.cardState.wasVideoStartTracked )
        {
            ALLog(@"Tracking video start for native ad (%@)", self.ad.adIdNumber);
            [self.sdk.postbackService dispatchPostbackAsync: self.ad.videoStartTrackingURL andNotify: nil];
            
            self.cardState.videoStartTracked = YES;
        }
    }
}

- (void)setInactive
{
    self.adImageView.alpha = 1.0f;
    self.adImageView.userInteractionEnabled = YES;
    self.videoView.alpha   = 0.0f;
    self.muteButton.alpha  = 0.0f;
    self.playButton.alpha  = 0.0f;
    
    // Reset background colors
    self.backgroundColor = kVideoViewBackgroundColor;
    self.videoView.playerLayer.backgroundColor = kVideoViewBackgroundColor.CGColor;
    self.videoView.backgroundColor = kVideoViewBackgroundColor;
    
    [self deactivateIfNeeded];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    ALLog(@"Video finished playing for native ad (%@)", self.ad.adIdNumber);
    
    self.cardState.lastMediaPlayerPosition = 0.0f;
    self.cardState.videoCompleted          = YES;
    self.cardState.replayOverlayVisible    = YES;
    
    [UIView animateWithDuration: 0.5f animations:^{
        self.muteButton.alpha        = 0.0f;
        self.replayOverlayView.alpha = 1.0f;
    }];
    
    [self handleVideoStopPlaying];
}

#pragma mark - Action Methods

- (void)didTapMuteButton:(UIButton *)muteButton
{
    self.cardState.muteState = self.cardState.muteState == ALMuteStateMuted ? ALMuteStateUnmuted : ALMuteStateMuted;
    [self updateMuteState];
}

- (void)didTapPlayButton:(UIButton *)sender
{
    [self playVideoIfInactive];
}

- (void)didTapReplayButton:(UIButton *)sender
{
    [self playVideoIfInactive];
}

- (void)didTapLearnMoreButton:(UIButton *)sender
{
    ALLog(@"Redirecting from Learn More button");
    [self handleClick];
}

- (void)didTapVideo:(UITapGestureRecognizer *)tapGesture
{
    if ( kVideoClicksThrough )
    {
        ALLog(@"Redirecting from video click");
        [self handleClick];
        [self setInactive];
    }
    else
    {
        if ( [self isCurrentlyPlayingVideo] )
        {
            [self setInactive];
            [UIView animateWithDuration: 0.5f animations:^{
                self.playButton.alpha = 1.0f;
            }];
        }
        else
        {
            [self playVideoIfInactive];
        }
    }
}

- (void)didTapAdImage:(UITapGestureRecognizer *)tapGesture
{
    ALLog(@"Redirecting from ad image click");
    [self handleClick];
}

- (void)handleClick
{
    if ( self.cardView )
    {
        [self.cardView handleClickForAd: self.ad];
    }
    else
    {
        [self.ad launchClickTarget];
    }
}

#pragma mark - Video Utility Methods

- (Float64)currentVideoPosition
{
    return CMTimeGetSeconds(self.videoView.player.currentTime);
}

- (Float64)videoDuration
{
    return CMTimeGetSeconds(self.videoPlayer.playerAsset.duration);
}

- (NSNumber *)percentViewed
{
    Float64 viewedRatio = [self currentVideoPosition] / [self videoDuration];
    return @( viewedRatio * 100 );
}

- (UIImage *)frameForVideoAtCurrentPosition
{
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset: self.videoPlayer.playerAsset];
    
    // Set the tolerance so we have a precise screenshot
    if ( [imageGenerator respondsToSelector: @selector(setRequestedTimeToleranceBefore:)] &&
        [imageGenerator respondsToSelector: @selector(setRequestedTimeToleranceAfter:)] )
    {
        [imageGenerator setRequestedTimeToleranceBefore: kCMTimeZero];
        [imageGenerator setRequestedTimeToleranceAfter:  kCMTimeZero];
    }
    
    return [UIImage imageWithCGImage: [imageGenerator copyCGImageAtTime: self.videoView.player.currentItem.currentTime
                                                             actualTime: nil
                                                                  error: nil]];
}

- (void)handleVideoStopPlaying
{
    self.videoView.playerLayer.backgroundColor = kVideoViewBackgroundColor.CGColor;
    
    if ( kRenderVideoScreenshotAsFallbackImage )
    {
        self.cardState.screenshot = [self frameForVideoAtCurrentPosition];
        self.adImageView.image    = self.cardState.screenshot;
        
        // Save the video rect, so at layoutSubviews: in an inactive card, we know what aspect ratio size the screenshot
        // should be rendered in.
        self.cardState.videoRect = self.videoView.playerLayer.videoRect;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: nil];
    
    // Track video completion if we havn't already
    if ( self.cardState.videoStarted )
    {
        NSURL* postbackUrl = [self.ad videoEndTrackingURL: [[self percentViewed] unsignedIntegerValue] firstPlay: self.cardState.firstPlayback];
        [self.sdk.postbackService dispatchPostbackAsync: postbackUrl andNotify: nil];
    }
    
    self.cardState.firstPlayback = NO;
}

- (BOOL)isCurrentlyPlayingVideo
{
    return self.videoView.player.rate > 0.0f;
}

- (void)seekToPosition:(Float64)position
{
    CMTimeScale timeScale = self.videoView.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(position, timeScale);
    [self.videoView.player seekToTime: time toleranceBefore: kCMTimeZero toleranceAfter: kCMTimeZero];
}

- (void)updateMuteState
{
    ALMuteState currentState = self.cardState.muteState;
    
    // If the current state is unspecify, determine if it should be muted or unmuted according to settings
    if ( currentState == ALMuteStateUnspecified )
    {
        currentState = kConfigIsMuted ? ALMuteStateMuted : ALMuteStateUnmuted;
        self.cardState.muteState = currentState;
    }
    
    if ( currentState == ALMuteStateMuted )
    {
        self.muteButton.selected    = YES;
        self.videoView.player.muted = YES;
    }
    else if ( currentState == ALMuteStateUnmuted )
    {
        self.muteButton.selected    = NO;
        self.videoView.player.muted = NO;
    }
}

#pragma mark - Utility Methods

- (void)clearView
{
    self.adImageView.image       = nil;
    self.adImageView.alpha       = 0.0f;
    self.adImageView.userInteractionEnabled = NO;
    self.videoView.alpha         = 0.0f;
    self.replayOverlayView.alpha = 0.0f;
    self.cardState               = nil;
}

// Called when resuming app or going back into the containing VC
- (void)reactivateIfNeeded
{
    if ( self.cardState.currentlyActive && [self.ad isVideoPrecached] )
    {
        [self autoplayIfRequired];
    }
}

// Called when pausing app or leaving VC *OR* when setting a card inactive
- (void)deactivateIfNeeded
{
    if ( [self isCurrentlyPlayingVideo] )
    {
        self.cardState.lastMediaPlayerPosition = [self currentVideoPosition];
        
        [self.videoPlayer stopVideo];
        [self handleVideoStopPlaying];
    }
}

- (void)destroyVideoPlayer
{
    // We don't need a video player; remove any one left behind.
    [self.videoPlayer stopVideo];
    self.videoPlayer = nil;
    
    [self.videoView removeFromSuperview];
    self.videoView = nil;
    
    [self.muteButton removeFromSuperview];
    [self.playButton removeFromSuperview];
    
    self.playButton = nil;
    self.muteButton = nil;
}

- (void)createVideoPlayerIfNeeded
{
    [self destroyVideoPlayer];
    
    // Create video player only for middle card
    if ( self.cardState.currentlyActive && [self.ad isVideoPrecached] )
    {
        self.videoPlayer = [[ALNativeAdVideoPlayer alloc] initWithMediaSource: nil];
        self.videoView.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        self.videoView.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        self.videoView = self.videoPlayer.videoView;
        [self.videoView.playerLayer setNeedsDisplay];
        self.videoView.backgroundColor = kVideoViewBackgroundColor;
        
        self.muteButton = [[UIButton alloc] init];
        self.muteButton.alpha = 0.0f;
        [self.muteButton addTarget: self action: @selector(didTapMuteButton:) forControlEvents: UIControlEventTouchUpInside];
        
        self.playButton = [[UIButton alloc] init];
        self.playButton.alpha = 0.0f;
        [self.playButton addTarget: self action: @selector(didTapPlayButton:) forControlEvents: UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *videoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapVideo:)];
        [self.videoView addGestureRecognizer: videoTapGesture];
        
        [self insertSubview: self.videoView  belowSubview: self.adImageView];
        [self insertSubview: self.playButton aboveSubview: self.adImageView];
        [self insertSubview: self.muteButton aboveSubview: self.videoView];
        
        // Popualte the assets
        [self.playButton setImage: [UIImage imageNamed: @"applovin_card_play"] forState: UIControlStateNormal];
        [self.muteButton setImage: [UIImage imageNamed: @"applovin_card_unmuted"] forState: UIControlStateNormal];
        [self.muteButton setImage: [UIImage imageNamed: @"applovin_card_muted"] forState: UIControlStateSelected];
    }
}

@end
