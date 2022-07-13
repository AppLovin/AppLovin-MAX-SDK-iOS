//
//  ALMAXMRecTableViewCell.h
//  AppLovin MAX Demo App - ObjC
//
//  Created by Alan Cao on 6/30/22.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALMAXMRecTableViewCell : UITableViewCell

- (void)configureWithAdView:(MAAdView *)adView;
- (void)stopAutoRefresh;

@end

NS_ASSUME_NONNULL_END
