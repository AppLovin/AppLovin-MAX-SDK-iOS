//
//  MAMediatedNetworkInfo.h
//  AppLovinSDK
//
//  Created by Ritam Sarmah on 2/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents information for a mediated network.
 */
@interface MAMediatedNetworkInfo : NSObject

/**
 * The name of the mediated network.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The class name of the adapter for the mediated network.
 */
@property (nonatomic, copy, readonly) NSString *adapterClassName;

/**
 * The version of the adapter for the mediated network.
 */
@property (nonatomic, copy, readonly) NSString *adapterVersion;

/**
 * The version of the mediated network’s SDK.
 */
@property (nonatomic, copy, readonly) NSString *sdkVersion;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
