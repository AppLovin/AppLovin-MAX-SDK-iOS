//
//  ALTapjoyMediationAdapter.m
//  Solitaire
//
//  Created by Thomas So on 10/19/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALTapjoyMediationAdapter.h"
#import <Tapjoy/Tapjoy.h>

#define ADAPTER_VERSION @"12.9.0.1"

@interface ALTapjoyMediationAdapterInterstitialDelegate : NSObject<TJPlacementDelegate, TJPlacementVideoDelegate>
@property (nonatomic,   weak) ALTapjoyMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(ALTapjoyMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface ALTapjoyMediationAdapterRewardedDelegate : NSObject<TJPlacementDelegate, TJPlacementVideoDelegate>
@property (nonatomic,   weak) ALTapjoyMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;
- (instancetype)initWithParentAdapter:(ALTapjoyMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface ALTapjoyMediationAdapter()

// Initialization
@property (nonatomic, copy, nullable) void(^oldCompletionHandler)(void);
@property (nonatomic, copy, nullable) void(^completionHandler)(MAAdapterInitializationStatus, NSString * _Nullable);

// Interstitial
@property (nonatomic, strong) TJPlacement *interstitialPlacement;
@property (nonatomic, strong) ALTapjoyMediationAdapterInterstitialDelegate *interstitialDelegate;

// Rewarded
@property (nonatomic, strong) TJPlacement *rewardedPlacement;
@property (nonatomic, strong) ALTapjoyMediationAdapterRewardedDelegate *rewardedDelegate;

@end

@implementation ALTapjoyMediationAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    if ( ![Tapjoy isConnected] )
    {
        NSString *sdkKey = [parameters.serverParameters al_stringForKey: @"sdk_key"];
        [self log: @"Initializing Tapjoy SDK with sdk key: %@...", sdkKey];
        
        self.completionHandler = completionHandler;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(tapjoyConnectCompleted:)
                                                     name: TJC_CONNECT_SUCCESS
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(tapjoyConnectCompleted:)
                                                     name: TJC_CONNECT_FAILED
                                                   object: nil];
        
        //[Tapjoy setDebugEnabled: [parameters isTesting]];
        
        // Update GDPR settings before initialization
        [self updateConsentWithParameters: parameters];
        
        [Tapjoy connect: sdkKey
                options: @{TJC_OPTION_ENABLE_LOGGING : @([parameters isTesting])}];
    }
    else
    {
        [self updateConsentWithParameters: parameters];
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
    }
}

- (void)tapjoyConnectCompleted:(NSNotification *)notification
{
    if ( [notification.name isEqualToString: TJC_CONNECT_SUCCESS] )
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        [self log: @"Tapjoy SDK initialized"];
        
        if ( self.completionHandler )
        {
            self.completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
            self.completionHandler = nil;
        }
    }
    else
    {
        // Tapjoy will attempt to re-connect, so wait for "SUCCESS"
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: TJC_CONNECT_FAILED
                                                      object: nil];
        
        [self log: @"Tapjoy SDK failed to initialized"];
        
        if ( self.completionHandler )
        {
            self.completionHandler(MAAdapterInitializationStatusInitializedFailure, nil);
            self.completionHandler = nil;
        }
    }
    
    if ( self.oldCompletionHandler )
    {
        self.oldCompletionHandler();
        self.oldCompletionHandler = nil;
    }
}

- (NSString *)SDKVersion
{
    return [Tapjoy getVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy {}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - MASignalProvider Methods

- (void)collectSignalWithParameters:(id<MASignalCollectionParameters>)parameters andNotify:(id<MASignalCollectionDelegate>)delegate
{
    // Update GDPR settings
    [self updateConsentWithParameters: parameters];
    
    NSString *token = [Tapjoy getUserToken];
    [delegate didCollectSignal: token];
}

#pragma mark - MAInterstitialAdapter Methods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Loading interstitial..."];
    
    if ( ![Tapjoy isConnected] )
    {
        [self log: @"Tapjoy SDK is not initialized"];
        
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.notInitialized];
        return;
    }
    
    // Update GDPR settings
    [self updateConsentWithParameters: parameters];
    
    self.interstitialDelegate = [[ALTapjoyMediationAdapterInterstitialDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.interstitialPlacement = [self placementWithParameters: parameters andNotify: self.interstitialDelegate];
    
    if ( self.interstitialPlacement )
    {
        [self.interstitialPlacement requestContent];
    }
    else
    {
        [delegate didFailToLoadInterstitialAdWithError: MAAdapterError.badRequest];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial..."];
    
    if ( [self.interstitialPlacement isContentReady] )
    {
        [self.interstitialPlacement showContentWithViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial ad not ready"];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Loading rewarded ad..."];
    
    if ( ![Tapjoy isConnected] )
    {
        [self log: @"Tapjoy SDK is not initialized"];
        
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.notInitialized];
        return;
    }
    
    // Update GDPR settings
    [self updateConsentWithParameters: parameters];
    
    self.rewardedDelegate = [[ALTapjoyMediationAdapterRewardedDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    self.rewardedPlacement = [self placementWithParameters: parameters andNotify: self.rewardedDelegate];
    
    if ( self.rewardedPlacement )
    {
        [self.rewardedPlacement requestContent];
    }
    else
    {
        [delegate didFailToLoadRewardedAdWithError: MAAdapterError.badRequest];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad..."];
    
    if ( [self.rewardedPlacement isContentReady] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        
        [self.rewardedPlacement showContentWithViewController: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [delegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

#pragma mark - Utility Methods

- (void)updateConsentWithParameters:(id<MAAdapterParameters>)parameters
{
    TJPrivacyPolicy *tjPrivacyPolicy = [Tapjoy getPrivacyPolicy];
    
    NSNumber *isAgeRestrictedUser = [self privacySettingForSelector: @selector(isAgeRestrictedUser) fromParameters: parameters];
    if ( isAgeRestrictedUser )
    {
        [tjPrivacyPolicy setBelowConsentAge: isAgeRestrictedUser.boolValue];
    }
    
    if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateApplies )
    {
        [tjPrivacyPolicy setSubjectToGDPR: YES];
        NSNumber *hasUserConsent = [self privacySettingForSelector: @selector(hasUserConsent) fromParameters: parameters];
        if ( hasUserConsent )
        {
            [tjPrivacyPolicy setUserConsent: hasUserConsent.boolValue ? @"1" : @"0"];
        }
    }
    else if ( self.sdk.configuration.consentDialogState == ALConsentDialogStateDoesNotApply )
    {
        [tjPrivacyPolicy setSubjectToGDPR: NO];
    }
    
    if ( ALSdk.versionCode >= 61100 )
    {
        NSNumber *isDoNotSell = [self privacySettingForSelector: @selector(isDoNotSell) fromParameters: parameters];
        if ( isDoNotSell )
        {
            [tjPrivacyPolicy setUSPrivacy: isDoNotSell.boolValue ? @"1YY-" : @"1YN-"];
        }
        else
        {
            [tjPrivacyPolicy setUSPrivacy: @"1---"];
        }
    }
}

- (nullable NSNumber *)privacySettingForSelector:(SEL)selector fromParameters:(id<MAAdapterParameters>)parameters
{
    // Use reflection because compiled adapters have trouble fetching `BOOL` from old SDKs and `NSNumber` from new SDKs (above 6.14.0)
    NSMethodSignature *signature = [[parameters class] instanceMethodSignatureForSelector: selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setSelector: selector];
    [invocation setTarget: parameters];
    [invocation invoke];
    
    // Privacy parameters return nullable `NSNumber` on newer SDKs
    if ( ALSdk.versionCode >= 6140000 )
    {
        NSNumber *__unsafe_unretained value;
        [invocation getReturnValue: &value];
        
        return value;
    }
    // Privacy parameters return BOOL on older SDKs
    else
    {
        BOOL rawValue;
        [invocation getReturnValue: &rawValue];
        
        return @(rawValue);
    }
}

- (nullable TJPlacement *)placementWithParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<TJPlacementDelegate>)delegate
{
    TJPlacement *placement = [TJPlacement placementWithName: parameters.thirdPartyAdPlacementIdentifier
                                             mediationAgent: @"applovin"
                                                mediationId: nil
                                                   delegate: delegate];
    placement.adapterVersion = self.adapterVersion;
    
    if ( [delegate conformsToProtocol: @protocol(TJPlacementVideoDelegate)] )
    {
        placement.videoDelegate = (id<TJPlacementVideoDelegate>) delegate;
    }
    
    if ( parameters.bidResponse )
    {
        NSData *jsonData = [parameters.bidResponse dataUsingEncoding: NSUTF8StringEncoding];
        
        // Attempt to deserialize
        NSError *error = nil;
        NSDictionary *auctionData = [NSJSONSerialization JSONObjectWithData: jsonData
                                                                    options: NSJSONReadingAllowFragments
                                                                      error: &error];
        if ( !error && auctionData )
        {
            placement.auctionData = auctionData;
        }
        else
        {
            [self log: @"Failed to load ad due to JSON deserialization error: %@", error];
            
            return nil;
        }
    }
    
    return placement;
}

+ (MAAdapterError *)toMaxError:(NSError *)tapjoyError
{
    NSInteger tapjoyErrorCode = tapjoyError.code;
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( tapjoyErrorCode )
    {
        case 204:
            adapterError = MAAdapterError.noFill;
            break;
        case -1001:
            adapterError = MAAdapterError.notInitialized;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: tapjoyErrorCode
               thirdPartySdkErrorMessage: tapjoyError.description];
#pragma clang diagnostic pop
}

@end

@implementation ALTapjoyMediationAdapterInterstitialDelegate

- (instancetype)initWithParentAdapter:(ALTapjoyMediationAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)requestDidSucceed:(TJPlacement *)placement
{
    if ( [placement isContentAvailable] )
    {
        [self.parentAdapter log: @"Interstitial request succeeded"];
    }
    else
    {
        [self.parentAdapter log: @"Interstitial request failed"];
        [self.delegate didFailToLoadInterstitialAdWithError: MAAdapterError.noFill];
    }
}

- (void)contentIsReady:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error
{
    [self.parentAdapter log: @"Interstitial failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALTapjoyMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadInterstitialAdWithError: adapterError];
}

- (void)contentDidAppear:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial shown"];
}

- (void)didClick:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)contentDidDisappear:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial hidden"];
    [self.delegate didHideInterstitialAd];
}

- (void)videoDidStart:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial video began"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)videoDidComplete:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Interstitial video completed"];
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMessage
{
    [self.parentAdapter log: @"Interstitial failed with error message: %@", errorMessage];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: MAAdapterError.unspecified.errorCode
                                                     errorString: MAAdapterError.unspecified.errorMessage
                                          thirdPartySdkErrorCode: 0
                                       thirdPartySdkErrorMessage: errorMessage];
    [self.delegate didFailToDisplayInterstitialAdWithError: adapterError];
#pragma clang diagnostic pop
}

@end

@implementation ALTapjoyMediationAdapterRewardedDelegate

- (instancetype)initWithParentAdapter:(ALTapjoyMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)requestDidSucceed:(TJPlacement *)placement
{
    if ( [placement isContentAvailable] )
    {
        [self.parentAdapter log: @"Rewarded request succeeded"];
    }
    else
    {
        [self.parentAdapter log: @"Rewarded request failed"];
        [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.noFill];
    }
}

- (void)contentIsReady:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error
{
    [self.parentAdapter log: @"Rewarded failed to load with error: %@", error];
    
    MAAdapterError *adapterError = [ALTapjoyMediationAdapter toMaxError: error];
    [self.delegate didFailToLoadRewardedAdWithError: adapterError];
}

- (void)contentDidAppear:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded shown"];
}

- (void)didClick:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)contentDidDisappear:(TJPlacement *)placement
{
    if ( [self hasGrantedReward] || [self.parentAdapter shouldAlwaysRewardUser] )
    {
        MAReward *reward = [self.parentAdapter reward];
        [self.parentAdapter log: @"Rewarded user with reward: %@", reward];
        [self.delegate didRewardUserWithReward: reward];
    }
    
    [self.parentAdapter log: @"Rewarded hidden"];
    [self.delegate didHideRewardedAd];
}

- (void)videoDidStart:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded video began"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)videoDidComplete:(TJPlacement *)placement
{
    [self.parentAdapter log: @"Rewarded video completed"];
    [self.delegate didCompleteRewardedAdVideo];
    
    self.grantedReward = YES;
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMessage
{
    [self.parentAdapter log: @"Rewarded failed with error message: %@", errorMessage];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    MAAdapterError *adapterError = [MAAdapterError errorWithCode: MAAdapterError.unspecified.errorCode
                                                     errorString: MAAdapterError.unspecified.errorMessage
                                          thirdPartySdkErrorCode: 0
                                       thirdPartySdkErrorMessage: errorMessage];
    [self.delegate didFailToDisplayRewardedAdWithError: adapterError];
#pragma clang diagnostic pop
}

@end
