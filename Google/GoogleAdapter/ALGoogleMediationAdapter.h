//
//  ALGoogleMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"
#import "MANativeAdAdapter.h"

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>
#import <GoogleMobileAds/GADAdFormat.h>
#import <GoogleMobileAds/GADRequest.h>

@class GADQueryInfo;

/// Completion handler for query creation. Returns query info or an error.
typedef void (^GADQueryInfoCreationCompletionHandler)(GADQueryInfo *_Nullable queryInfo,
                                                      NSError *_Nullable error);
/// Query info used in requests.
@interface GADQueryInfo : NSObject
/// Query string used in requests.
@property(nonatomic, readonly, nonnull) NSString *query;
/// Uniquely identifies a request. The ad string response contains a matching identifier. See
/// GADAdInfo_Preview.h for more information.
@property(nonatomic, readonly, nonnull) NSString *requestIdentifier;
/// Creates query info that can be used as input in a Google request. Calls completionHandler
/// asynchronously on the main thread once query info has been created or when an error occurs.
+ (void)createQueryInfoWithRequest:(nullable GADRequest *)request
                          adFormat:(GADAdFormat)adFormat
                 completionHandler:(nonnull GADQueryInfoCreationCompletionHandler)completionHandler;

@end

/// Ad string request extension.
@interface GADRequest (AdString)

/// Ad string that represents an ad response. The SDK will render this ad and ignore all other
/// targeting information set on this request.
@property(nonatomic, copy, nullable) NSString *adString;

@end

@interface ALGoogleMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MARewardedInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
