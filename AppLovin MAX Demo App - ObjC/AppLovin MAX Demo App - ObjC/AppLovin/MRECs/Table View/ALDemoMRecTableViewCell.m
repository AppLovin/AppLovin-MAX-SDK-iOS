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

BOOL isAdViewRemovedFromSubview = NO;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.textLabel.text = nil;
    MAAdView *adView = self.contentView.subviews.firstObject;
    [adView removeFromSuperview];
    isAdViewRemovedFromSubview = YES;
}

- (void)configure
{
    // MREC width and height are 300 and 250 respectively, on iPhone and iPad
    CGFloat height = 250;
    CGFloat width = 300;

    // Center the MREC
    self.adView.frame = CGRectMake(self.contentView.center.x - 150, self.contentView.frame.origin.y, width, height);

    // Set background or background color for MREC ads to be fully functional
    self.adView.backgroundColor = [UIColor whiteColor];
    
    // Avoid table view scrolling lag if adView hasn't been removed
    if (isAdViewRemovedFromSubview)
    {
        [self.contentView addSubview: self.adView];
    }
}

@end
