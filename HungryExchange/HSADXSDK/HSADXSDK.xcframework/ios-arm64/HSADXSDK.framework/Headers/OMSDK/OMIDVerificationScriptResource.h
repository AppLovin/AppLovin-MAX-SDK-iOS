//
//  OMIDVerificationScriptResource.h
//  AppVerificationLibrary
//
//  Created by Daria on 06/06/2017.
//

#import <Foundation/Foundation.h>

/**
 *  Details about the verification provider which will be supplied to the ad session.
 */
@interface OMIDHungrystudioVerificationScriptResource : NSObject

@property(nonatomic, readonly, nonnull) NSURL *URL;
@property(nonatomic, readonly, nullable) NSString *vendorKey;
@property(nonatomic, readonly, nullable) NSString *parameters;

/**
 *  Initializes new verification script resource instance which requires vendor specific verification parameters.
 *
 *  When calling this method all arguments are mandatory.
 *
 * @param vendorKey It is used to uniquely identify the verification provider.
 * @param URL The URL to be injected into the OMID managed JavaScript execution environment.
 * @param parameters The parameters which the verification provider script is expecting for the ad session.
 * @return A new verification script resource instance, or nil if any of the parameters are either null or blank.
 */
- (nullable instancetype)initWithURL:(nonnull NSURL *)URL
                           vendorKey:(nonnull NSString *)vendorKey
                          parameters:(nonnull NSString *)parameters;

/**
 *  Initializes new verification script resource instance which does not require any vendor specific verification parameters.
 *
 *  When calling this method all arguments are mandatory.
 *
 * @param URL The URL to be injected into the OMID managed JavaScript execution environment.
 * @return A new verification script resource instance, or nil if URL is nil or blank.
 */
- (nullable instancetype)initWithURL:(nonnull NSURL *)URL;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
