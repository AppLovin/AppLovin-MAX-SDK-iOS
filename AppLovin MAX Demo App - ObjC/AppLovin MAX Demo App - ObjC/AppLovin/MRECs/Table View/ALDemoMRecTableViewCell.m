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

MAAdView *cellAdView;
/*
 TODO: There's a bug
 When: Loading an adView into an appearing cell 5x while keeping another adView cell in view
 What: The adView cell that's fully in view disappears
 */

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [cellAdView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
    [cellAdView stopAutoRefresh];
    
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
    cellAdView = adView;
    cellAdView.backgroundColor = [UIColor blackColor];
    cellAdView.translatesAutoresizingMaskIntoConstraints = false;
    [cellAdView startAutoRefresh];
    
    [self.contentView addSubview: cellAdView];
    [NSLayoutConstraint activateConstraints: @[
        [cellAdView.widthAnchor constraintEqualToConstant: 300],
        [cellAdView.heightAnchor constraintEqualToConstant: 250],
        [cellAdView.centerXAnchor constraintEqualToAnchor: self.contentView.centerXAnchor],
        [cellAdView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor],
        [cellAdView.bottomAnchor constraintLessThanOrEqualToAnchor: self.contentView.bottomAnchor]
    ]];
}

@end
