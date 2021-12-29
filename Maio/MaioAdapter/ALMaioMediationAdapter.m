//
//  ALMaioMediationAdapter.m
//  MaioAdapter
//
//  Created by Harry Arakkal on 7/1/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALMaioMediationAdapter.h"
#import "ALAtomicBoolean.h"
#import "ALMediationAdapterRouter.h"
#import <Maio/Maio.h>
#import <Maio/MaioDelegate.h>
#import "ALUtils.h"
#import "NSString+ALUtils.h"
#import "NSDictionary+ALUtils.h"

#define ADAPTER_VERSION @"1.5.8.0"

@interface ALMaioMediationAdapterRouter : ALMediationAdapterRouter<MaioDelegate>

@property (nonatomic, strong) ALAtomicBoolean *isShowingAd;
@property (nonatomic, assign, getter=hasGrantedReward) BOOL grantedReward;

@property (nonatomic, copy, nullable) void(^oldCompletionHandler)(void);
@property (nonatomic, copy, nullable) void(^newCompletionHandler)(MAAdapterInitializationStatus, NSString * _Nullable);

@end

@interface ALMaioMediationAdapter()

@property (nonatomic, strong, readonly) ALMaioMediationAdapterRouter *router;
@property (nonatomic, copy) NSString *zoneId;

@end

@implementation ALMaioMediationAdapter
@dynamic router;

static ALAtomicBoolean              *ALMaioInitialized;
static MAAdapterInitializationStatus ALMaioIntializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    
    ALMaioInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters withCompletionHandler:(void (^)(void))completionHandler
{
    if ( [ALMaioInitialized compareAndSet: NO update: YES] )
    {
        NSString *mediaId = [parameters.serverParameters al_stringForKey: @"media_id"];
        
        [self log: @"Initializing Maio with media id: %@", mediaId];
        
        if ( [parameters isTesting] )
        {
            [Maio setAdTestMode: YES];
        }
        
        self.router.oldCompletionHandler = completionHandler;
        
        [Maio startWithMediaId: mediaId delegate: self.router];
    }
    else
    {
        [self log: @"Maio already initialized"];
        completionHandler();
    }
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters
               completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler
{
    if ( [ALMaioInitialized compareAndSet: NO update: YES] )
    {
        NSString *mediaId = [parameters.serverParameters al_stringForKey: @"media_id"];
        
        [self log: @"Initializing Maio with media id: %@", mediaId];
        
        if ( [parameters isTesting] )
        {
            [Maio setAdTestMode: YES];
        }
        
        self.router.newCompletionHandler = completionHandler;
        ALMaioIntializationStatus = MAAdapterInitializationStatusInitializing;
        
        [Maio startWithMediaId: mediaId delegate: self.router];
    }
    else
    {
        [self log: @"Maio already initialized"];
        completionHandler(ALMaioIntializationStatus, nil);
    }
}

- (NSString *)SDKVersion
{
    return [Maio sdkVersion];
}

- (NSString *)adapterVersion
{
    return ADAPTER_VERSION;
}

- (void)destroy
{
    [self.router removeAdapter: self forPlacementIdentifier: self.zoneId];
}

#pragma mark - MAInterstitialAdapterMethods

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    self.zoneId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading interstitial ad: %@...", self.zoneId];
    
    [self.router addInterstitialAdapter: self delegate: delegate forPlacementIdentifier: self.zoneId];
    
    // `canShowAtZoneId:` will callback to `maioDidFail:reason:` with `MaioFailReasonIncorrectZoneId` - Android does not (hence extra check)
    if ( [Maio canShowAtZoneId: self.zoneId] )
    {
        [self.router didLoadAdForPlacementIdentifier: self.zoneId];
    }
    // Maio might lose out on the first impression.
    else
    {
        [self log: @"Ad failed to load for this zone: %@", self.zoneId];
        [self.router didFailToLoadAdForPlacementIdentifier: self.zoneId error: MAAdapterError.noFill];
    }
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate
{
    [self log: @"Showing interstitial ad %@", self.zoneId];
    
    [self.router addShowingAdapter: self];
    
    if ( [Maio canShowAtZoneId: self.zoneId] )
    {
        [Maio showAtZoneId: self.zoneId vc: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Interstitial not ready"];
        [self.router didFailToDisplayAdForPlacementIdentifier: self.zoneId error: MAAdapterError.adNotReady];
    }
}

#pragma mark - MARewardedAdapter Methods

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self.zoneId = parameters.thirdPartyAdPlacementIdentifier;
    
    [self log: @"Loading rewarded ad: %@...", self.zoneId];
    
    [self.router addRewardedAdapter: self delegate: delegate forPlacementIdentifier: self.zoneId];
    
    if ( [Maio canShowAtZoneId: self.zoneId] )
    {
        [self.router didLoadAdForPlacementIdentifier: self.zoneId];
    }
    // Maio might lose out on the first impression.
    else
    {
        [self log: @"Ad failed to load for this zone: %@", self.zoneId];
        [self.router didFailToLoadAdForPlacementIdentifier: self.zoneId error: MAAdapterError.noFill];
    }
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    [self log: @"Showing rewarded ad %@", self.zoneId];
    
    [self.router addShowingAdapter: self];
    
    if ( [Maio canShowAtZoneId: self.zoneId] )
    {
        // Configure reward from server.
        [self configureRewardForParameters: parameters];
        [Maio showAtZoneId: self.zoneId vc: [ALUtils topViewControllerFromKeyWindow]];
    }
    else
    {
        [self log: @"Rewarded ad not ready"];
        [self.router didFailToDisplayAdForPlacementIdentifier: self.zoneId error: MAAdapterError.adNotReady];
    }
}

#pragma mark - Dynamic Properties

- (ALMaioMediationAdapterRouter *)router
{
    return [ALMaioMediationAdapterRouter sharedInstance];
}

@end

@implementation ALMaioMediationAdapterRouter

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.isShowingAd = [[ALAtomicBoolean alloc] init];
    }
    return self;
}

#pragma mark - Override for Ad Show

- (void)addShowingAdapter:(id<MAAdapter>)showingAdapter
{
    [super addShowingAdapter: showingAdapter];
    
    // Maio uses the same callback for [AD LOAD FAILED] and [AD DISPLAY FAILED] callbacks
    [self.isShowingAd set: YES];
}

#pragma mark - Maio Delegate Methods

- (void)maioDidInitialize
{
    [self log: @"Maio SDK initialized"];
    
    if ( self.oldCompletionHandler )
    {
        self.oldCompletionHandler();
        self.oldCompletionHandler = nil;
    }
    
    if ( self.newCompletionHandler )
    {
        ALMaioIntializationStatus = MAAdapterInitializationStatusInitializedUnknown;
        
        self.newCompletionHandler(ALMaioIntializationStatus, nil);
        self.newCompletionHandler = nil;
    }
}

// Does not refer to a specific ad, but if ads can show in general.
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue
{
    if ( newValue )
    {
        [self log: @"Maio can show ads: %@", zoneId];
    }
    else
    {
        [self log: @"Maio cannot show ads: %@", zoneId];
    }
}

- (void)maioWillStartAd:(NSString *)zoneId
{
    [self log: @"Ad video started: %@", zoneId];
    [self didDisplayAdForPlacementIdentifier: zoneId];
    [self didStartRewardedVideoForPlacementIdentifier: zoneId];
}

- (void)maioDidClickAd:(NSString *)zoneId
{
    [self log: @"Ad clicked: %@", zoneId];
    [self didClickAdForPlacementIdentifier: zoneId];
}

- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam
{
    [self log: @"Did finish ad=%@, playtime=%ld, skipped=%d, rewardParam=%@", zoneId, playtime, skipped, rewardParam];
    
    if ( !skipped )
    {
        self.grantedReward = YES;
    }
    
    [self didCompleteRewardedVideoForPlacementIdentifier: zoneId];
}

- (void)maioDidCloseAd:(NSString *)zoneId
{
    [self log: @"Ad closed: %@", zoneId];
    
    if ( [self hasGrantedReward] || [self shouldAlwaysRewardUserForPlacementIdentifier: zoneId] )
    {
        MAReward *reward = [self rewardForPlacementIdentifier: zoneId];
        [self log: @"Rewarded ad user with reward: %@", reward];
        [self didRewardUserForPlacementIdentifier: zoneId withReward: reward];
        
        self.grantedReward = NO;
    }
    
    [self.isShowingAd set: NO];
    
    [self didHideAdForPlacementIdentifier: zoneId];
}

- (void)maioDidFail:(NSString *)zoneId reason:(MaioFailReason)reason
{
    MAAdapterError *error = [ALMaioMediationAdapterRouter toMaxError: reason];
    
    if ( [self.isShowingAd compareAndSet: YES update: NO] )
    {
        [self log: @"Ad failed to display with Maio reason: %@ and MAX error: %@", [self reasonToString: reason], error];
        [self didFailToDisplayAdForPlacementIdentifier: zoneId error: error];
    }
    else
    {
        [self log: @"Ad failed to load with Maio reason: %@, and MAX error: %@", [self reasonToString: reason], error];
        [self didFailToLoadAdForPlacementIdentifier: zoneId error: error];
    }
}

#pragma mark - Helper functions

+ (MAAdapterError *)toMaxError:(MaioFailReason)maioErrorCode
{
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch ( maioErrorCode )
    {
        case MaioFailReasonAdStockOut:
            adapterError = MAAdapterError.noFill;
            break;
        case MaioFailReasonNetworkConnection:
            adapterError = MAAdapterError.noConnection;
            break;
        case MaioFailReasonNetworkClient:
            adapterError = MAAdapterError.badRequest;
            break;
        case MaioFailReasonNetworkServer:
        case MaioFailReasonSdk:
            adapterError = MAAdapterError.serverError;
            break;
        case MaioFailReasonDownloadCancelled:
            adapterError = MAAdapterError.adNotReady;
            break;
        case MaioFailReasonVideoPlayback:
            adapterError = MAAdapterError.internalError;
            break;
        case MaioFailReasonIncorrectMediaId:
        case MaioFailReasonIncorrectZoneId:
            adapterError = MAAdapterError.invalidConfiguration;
            break;
        case MaioFailReasonNotFoundViewContext:
        case MaioFailReasonUnknown:
            adapterError = MAAdapterError.unspecified;
            break;
    }
    
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: maioErrorCode
               thirdPartySdkErrorMessage: @""];
}

- (NSString *)reasonToString:(MaioFailReason)reason
{
    NSString *errorString;
    
    if ( reason == MaioFailReasonAdStockOut )
    {
        errorString = @"Ad Stock Out";
    }
    else if ( reason == MaioFailReasonNetworkConnection )
    {
        errorString = @"Network Connection";
    }
    else if ( reason == MaioFailReasonNetworkClient )
    {
        errorString = @"Client Network";
    }
    else if ( reason == MaioFailReasonNetworkServer )
    {
        errorString = @"Server Network";
    }
    else if ( reason == MaioFailReasonSdk )
    {
        errorString = @"Maio SDK Issue";
    }
    else if ( reason == MaioFailReasonDownloadCancelled )
    {
        errorString = @"Download Cancelled";
    }
    else if ( reason == MaioFailReasonVideoPlayback )
    {
        errorString = @"Video Playback Issue";
    }
    else if ( reason == MaioFailReasonIncorrectMediaId )
    {
        errorString = @"Incorrect media id";
    }
    else if ( reason == MaioFailReasonIncorrectZoneId )
    {
        errorString = @"Incorrect zone id";
    }
    else
    {
        errorString = @"Unknown Issue";
    }
    
    return errorString;
}

@end

