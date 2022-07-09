//
//  ALDemoMRecTableViewCell.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Alan Cao on 6/30/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALDemoMRecTableViewCell.h"
#import <AppLovinSDK/AppLovinSDK.h>

@implementation ALDemoMRecTableViewCell
/*
 TODO: There's a bug
 When: Loading an adView into an appearing cell 5x while keeping another adView cell in view
 What: The adView cell that's fully in view disappears
 */

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
    [self.adView stopAutoRefresh];
    
    for ( UIView *subview in self.contentView.subviews )
    {
        if ( [subview isKindOfClass: [MAAdView class]] )
        {
            [subview removeFromSuperview];
        }
    }
}

- (void)configureWith:(MAAdView *)adView
{
    [self setAdView: adView];
    [self.adView startAutoRefresh];
    self.adView.backgroundColor = [UIColor blackColor];
    self.adView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.contentView addSubview: self.adView];
    [NSLayoutConstraint activateConstraints: @[
        [self.adView.widthAnchor constraintEqualToConstant: 300],
        [self.adView.heightAnchor constraintEqualToConstant: 250],
        [self.adView.centerXAnchor constraintEqualToAnchor: self.contentView.centerXAnchor],
        [self.adView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor],
        [self.adView.bottomAnchor constraintLessThanOrEqualToAnchor: self.contentView.bottomAnchor]
    ]];
}

@end
