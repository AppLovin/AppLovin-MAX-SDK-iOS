//
//  ALUserService.h
//  AppLovinSDK
//
//  Created by Thomas So on 10/2/18.
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * Service object for performing user-related tasks.
 */
@interface ALUserService : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface ALUserService(ALDeprecated)
- (void)showConsentDialogWithCompletionHandler:(void (^_Nullable)(void))completionHandler __deprecated_msg("This version of the consent flow has been deprecated as of v7.0.0, please refer to our documentation for enabling the new consent flow.");
@end

NS_ASSUME_NONNULL_END
