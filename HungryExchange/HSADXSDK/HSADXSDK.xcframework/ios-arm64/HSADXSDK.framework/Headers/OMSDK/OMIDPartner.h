//
//  OMIDPartner.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import <Foundation/Foundation.h>

/**
 *  Details about the integration partner which will be supplied to the ad session.
 */
@interface OMIDHungrystudioPartner : NSObject

@property(nonatomic, readonly, nonnull) NSString *name;
@property(nonatomic, readonly, nonnull) NSString *versionString;

/**
 *  Initializes new partner instance providing both name and versionString.
 *
 *  Both name and version are mandatory.
 *
 * @param name It is used to uniquely identify the integration partner.
 * @param versionString It is used to uniquely identify the integration partner.
 * @return A new partner instance, or nil if any of the parameters are either null or blank
 */
- (nullable instancetype)initWithName:(nonnull NSString *)name
                        versionString:(nonnull NSString *)versionString;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
