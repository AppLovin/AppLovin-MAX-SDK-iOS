//
//  ALVideoView.h
//  sdk
//
//  Created by Matt Szaro on 6/23/14.
//
//

@import AppLovinSDK;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface ALNativeAdVideoView : UIView

@property (strong, nonatomic, readonly) AVPlayer *player;
@property (strong, nonatomic, readonly) AVPlayerLayer* playerLayer;

- (instancetype)initWithPlayer:(AVPlayer *)aPlayer;

@end

NS_ASSUME_NONNULL_END
