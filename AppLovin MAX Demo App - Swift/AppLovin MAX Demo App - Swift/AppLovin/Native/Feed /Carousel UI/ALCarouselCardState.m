//
//  ALCarouselCardState.m
//  sdk
//
//  Created by Matt Szaro on 4/17/15.
//
//

#import "ALCarouselCardState.h"

@implementation ALCarouselCardState

+(instancetype) cardStateForCarousel
{
    ALCarouselCardState* state = [[[self class] alloc] init];
    
    state.muteState = ALMuteStateUnspecified;
    state.firstPlayback = YES;
    
    return state;
}

+(instancetype) cardStateForSingleCard
{
    ALCarouselCardState* state = [[[self class] alloc] init];
    
    state.muteState = ALMuteStateUnspecified;
    state.currentlyActive = YES;
    state.firstPlayback = YES;
    
    return state;
}

@end