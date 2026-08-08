//
//  OMIDScriptInjector.h
//  AppVerificationLibrary
//
//  Created by Daria on 21/06/2017.
//

#import <Foundation/Foundation.h>

/**
 *  Utility class which enables integration partners to use a standard approach for injecting OM SDK JS into the served tag HTML content.
 */
@interface OMIDHungrystudioScriptInjector : NSObject

/*
 Injects the downloaded OMID JS content into the served HTML.
 @param scriptContent containing the OMID JS service content to be injected into the hidden tracking web view.
 @param html of the tag content which should be modified to include the downloaded OMID JS content.
 @param error If an error occurs, contains an NSError object.
 @return modified HTML including OMID JS or nil if an error occurs.
 */
+ (nullable NSString *)injectScriptContent:(nonnull NSString *)scriptContent
                                  intoHTML:(nonnull NSString *)html
                                     error:(NSError *_Nullable *_Nullable)error;

@end
