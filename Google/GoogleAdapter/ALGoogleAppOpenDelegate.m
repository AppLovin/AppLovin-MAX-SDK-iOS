//
//  ALGoogleAppOpenDelegate.m
//  GoogleAdapter
//
//  Created by Vedant Mehta on 8/11/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import "ALGoogleAppOpenDelegate.h"

@interface ALGoogleAppOpenDelegate ()
@property (nonatomic, weak) ALGoogleMediationAdapter *parentAdapter;
@property (nonatomic, copy) NSString *placementIdentifier;
@property (nonatomic, strong) id<MAAppOpenAdapterDelegateTemp> delegate;
@end

@implementation ALGoogleAppOpenDelegate

- (instancetype)initWithParentAdapter:(ALGoogleMediationAdapter *)parentAdapter
                  placementIdentifier:(NSString *)placementIdentifier
                            andNotify:(id<MAAppOpenAdapterDelegateTemp>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.placementIdentifier = placementIdentifier;
        self.delegate = delegate;
    }
    return self;
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad shown: %@", self.placementIdentifier];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: -4205
                                                     errorString: @"Ad Display Failed"
                                          thirdPartySdkErrorCode: error.code
                                       thirdPartySdkErrorMessage: error.localizedDescription];
#pragma clang diagnostic pop
    
    [self.parentAdapter log: @"App open ad (%@) failed to show with error: %@", self.placementIdentifier, adapterError];
    [self.delegate didFailToDisplayAppOpenAdWithError: adapterError];
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad impression recorded: %@", self.placementIdentifier];
    [self.delegate didDisplayAppOpenAd];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad click recorded: %@", self.placementIdentifier];
    [self.delegate didClickAppOpenAd];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    [self.parentAdapter log: @"App open ad hidden: %@", self.placementIdentifier];
    [self.delegate didHideAppOpenAd];
}

@end
