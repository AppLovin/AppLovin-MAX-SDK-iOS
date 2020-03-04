//
//  ALVideoPlayer.h
//  sdk
//
//  Created by Matt Szaro on 6/23/14.
//
//

@import AppLovinSDK;
@import AVFoundation;
@import CoreMedia;
#import "ALNativeAdVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALNativeAdVideoPlayer : NSObject

@property (strong, nonatomic, readonly)  ALNativeAdVideoView* videoView;
@property (strong, nonatomic, readonly)  AVPlayerItem* playerItem;
@property (strong, nonatomic, readonly)  AVAsset* playerAsset;
@property (strong, nonatomic, readwrite)  NSURL* mediaSource;

-(instancetype) initWithMediaSource: (nullable NSURL*) aMediaSource;

-(void) playVideo;
-(void) stopVideo;

@end

NS_ASSUME_NONNULL_END
