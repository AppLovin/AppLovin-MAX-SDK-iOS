//
//  ALVideoView.m
//  sdk
//
//  Created by Matt Szaro on 6/23/14.
//
//

#import "ALNativeAdVideoView.h"

@interface ALNativeAdVideoView()
@property (strong, nonatomic, readwrite) AVPlayer *player;
@end

@implementation ALNativeAdVideoView
@dynamic player, playerLayer;

-(instancetype) initWithPlayer:(AVPlayer *)aPlayer
{
    self = [super init];
    if(self)
    {
        self.player = aPlayer;
    }
    return self;
}

+(Class) layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayerLayer*) playerLayer
{
    return (AVPlayerLayer*) self.layer;
}

-(AVPlayer*) player
{
    return self.playerLayer.player;
}

-(void) setPlayer: (AVPlayer *) aPlayer
{
    self.playerLayer.player = aPlayer;
}

@end
