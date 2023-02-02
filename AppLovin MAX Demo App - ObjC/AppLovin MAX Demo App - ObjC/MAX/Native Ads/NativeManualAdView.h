//
//  NativeManualAdView.h
//  AppLovin MAX Demo App - ObjC
//
//  Created by Avi Leung on 2/2/23.
//  Copyright © 2023 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NativeManualAdView : MANativeAdView
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *starRatingContentViewHeightConstraint;
@end

NS_ASSUME_NONNULL_END
