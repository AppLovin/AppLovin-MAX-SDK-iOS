//
//  ALVideoPlayer.m
//  sdk
//
//  Created by Matt Szaro on 6/23/14.
//
//

#import "ALNativeAdVideoPlayer.h"

@interface ALNativeAdVideoPlayer()

@property (strong, nonatomic, readwrite)  ALNativeAdVideoView* videoView;
@property (strong, nonatomic, readwrite)  AVPlayerItem* playerItem;
@property (strong, nonatomic, readwrite)  AVAsset* playerAsset;
@property (strong, nonatomic, readwrite)  AVPlayer* player;

@end

@implementation ALNativeAdVideoPlayer

-(instancetype) initWithMediaSource:(NSURL *)aMediaSource
{
    self = [super init];
    if(self)
    {
        self.mediaSource = aMediaSource;
        self.videoView = [self createVideoView];
    }
    return self;
}

-(ALNativeAdVideoView*) createVideoView
{
    self.playerAsset = [AVAsset assetWithURL: self.mediaSource];
    self.playerItem = [AVPlayerItem playerItemWithAsset: self.playerAsset];
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
    
    ALNativeAdVideoView* videoView = [[ALNativeAdVideoView alloc] initWithPlayer: self.player];
    videoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    return videoView;
}

-(void) playVideo
{
    [self.videoView.player play];
}

-(void) stopVideo
{
     [self.videoView.player pause];
}

-(void) setMediaSource:(NSURL *)mediaSource
{
    if (![_mediaSource isEqual: mediaSource]) {
        
        _mediaSource = mediaSource;
        
        self.playerAsset = [AVAsset assetWithURL: self.mediaSource];
        self.playerItem = [AVPlayerItem playerItemWithAsset: self.playerAsset];
        
        [self.player replaceCurrentItemWithPlayerItem: self.playerItem];
    }
}
@end
