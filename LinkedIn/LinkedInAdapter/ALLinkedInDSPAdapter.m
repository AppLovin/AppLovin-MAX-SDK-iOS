//
//  ALLinkedInDSPAdapter.m
//  AppLovinSDK
//
//  Created by Thomas So on 11/17/22.
//

#import "ALLinkedInDSPAdapter.h"
#import <LinkedinAudienceNetwork/LinkedinAudienceNetwork.h>

#define ADAPTER_VERSION @"1.2.1.0"

@implementation ALLinkedInDSPAdapter

static ALAtomicBoolean              *ALLinkedInInitialized;
static MAAdapterInitializationStatus ALLinkedInInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALLinkedInInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - Adapter Protocol

- (NSString *)SDKVersion
{
    // LI team requests no-op on < iOS 12
    if ( @available(iOS 12.0, *) )
    {
        return [LIAudienceNetwork sdkVersion];
    }
    else
    {
        return @"N/A";
    }
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler
{
    // LI team requests no-op on < iOS 12
    if ( @available(iOS 12.0, *) )
    {
        if ( [ALLinkedInInitialized compareAndSet: NO update: YES] )
        {
            ALLinkedInInitializationStatus = MAAdapterInitializationStatusInitializing;
            
            NSString *sdkKey = parameters.serverParameters[@"sdk_key"];
            
            [self d: @"Initializing SDK..."];
            
            [LIAudienceNetwork startWithKey: sdkKey completion:^(NSError *error) {
                
                if ( error )
                {
                    [self e: @"SDK failed to initialize with error: %@", error];
                    
                    ALLinkedInInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                    completionHandler(ALLinkedInInitializationStatus, error.localizedDescription);
                    
                    return;
                }
                
                [self d: @"SDK initialized"];
                
                ALLinkedInInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALLinkedInInitializationStatus, nil);
            }];
        }
        else
        {
            completionHandler(ALLinkedInInitializationStatus, nil);
        }
    }
    else
    {
        completionHandler(MAAdapterInitializationStatusAdapterNotInitialized, nil);
    }
}

- (void)destroy {}

#pragma mark - Signal Provider Protocol

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    // LI team requests no-op on < iOS12
    if ( @available(iOS 12.0, *) )
    {
        [delegate didCollectSignal: LIAudienceNetwork.bidderToken];
    }
    else
    {
        [delegate didFailToCollectSignalWithErrorMessage: @"Below iOS 12"];
    }
}

@end
