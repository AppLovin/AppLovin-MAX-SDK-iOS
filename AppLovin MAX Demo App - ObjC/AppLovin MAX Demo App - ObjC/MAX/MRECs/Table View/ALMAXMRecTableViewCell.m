//
//  ALMAXMRecTableViewCell.m
//  AppLovin MAX Demo App - ObjC
//
//  Created by Alan Cao on 6/30/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMAXMRecTableViewCell.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface ALMAXMRecTableViewCell()

@property (nonatomic, strong, nullable) MAAdView *adView;

@end

@implementation ALMAXMRecTableViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
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
    self.adView = adView;
    self.adView.backgroundColor = [UIColor blackColor];
    self.adView.translatesAutoresizingMaskIntoConstraints = false;
    [self.adView startAutoRefresh];
    
    [self.contentView addSubview: self.adView];
    [NSLayoutConstraint activateConstraints: @[
        [self.adView.widthAnchor constraintEqualToConstant: 300],
        [self.adView.heightAnchor constraintEqualToConstant: 250],
        [self.adView.centerXAnchor constraintEqualToAnchor: self.contentView.centerXAnchor],
        [self.adView.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor],
        [self.adView.bottomAnchor constraintLessThanOrEqualToAnchor: self.contentView.bottomAnchor]
    ]];
}

- (void)stopAutoRefresh
{
    [self.adView setExtraParameterForKey: @"allow_pause_auto_refresh_immediately" value: @"true"];
    [self.adView stopAutoRefresh];
}

@end
