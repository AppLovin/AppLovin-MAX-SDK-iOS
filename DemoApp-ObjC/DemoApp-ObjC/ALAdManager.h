//
//  ALAdManager.h
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Shared class responsible for all ad operations.
 */
@interface ALAdManager : NSObject

/**
 * Get the shared instance of the ad manager class.
 */
@property (class, nonatomic, strong, readonly) ALAdManager *shared;

/**
 * Initializes the AppLovin SDK and begin loading ads _after_ the completion callback is fired.
 */
- (void)initializeSdkWithCompletionHandler:(nullable ALSdkInitializationCompletionHandler)completionHandler;

#pragma mark - Banner Ads

#pragma mark - Interstitial Ads

#pragma mark - Rewarded Ads


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
