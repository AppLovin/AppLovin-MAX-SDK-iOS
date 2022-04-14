//
//  Criteo.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#ifndef Criteo_h
#define Criteo_h

#import <Foundation/Foundation.h>
#import <CriteoPublisherSdk/CRAdUnit.h>
#import <CriteoPublisherSdk/CRBid.h>
#import <CriteoPublisherSdk/CRContextData.h>
#import <CriteoPublisherSdk/CRSKAdNetworkInfo.h>
#import <CriteoPublisherSdk/CRUserData.h>

/** Bid response handler, bid can be nil on purpose */
typedef void (^CRBidResponseHandler)(CRBid *_Nullable bid);

NS_ASSUME_NONNULL_BEGIN

@interface Criteo : NSObject

#pragma mark - Lifecycle

/**
 * Use sharedCriteo singleton accessor, do not init your own instance
 * Note: Initialization is expected through registerCriteoPublisherId:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Criteo shared instance singleton
 * Note: Initialization is expected through registerCriteoPublisherId:
 * @return The Criteo singleton
 */
+ (nonnull instancetype)sharedCriteo;

/**
 * Initialize Criteo singleton
 * @param criteoPublisherId Publisher Identifier
 * @param adUnits AdUnits array
 */
- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits;

#pragma mark - Consent management

/** Set a custom opt-out/opt-in with same behaviour as the CCPA (US Privacy). */
- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut;

/** Set the privacy consent string owned by the Mopub SDK. */
- (void)setMopubConsent:(NSString *)mopubConsent;

#pragma mark - User data

/** Set data on the current user which will be used to bid based on context. */
- (void)setUserData:(CRUserData *)userData;

#pragma mark - Bidding

/**
 * Request asynchronously a bid from Criteo
 * @param adUnit The ad unit to request
 * @param responseHandler the handler called on response. Responded bid can be nil.
 * Note: responseHandler is invoked on main queue
 */
- (void)loadBidForAdUnit:(CRAdUnit *)adUnit responseHandler:(CRBidResponseHandler)responseHandler;

/**
 * Request asynchronously a bid from Criteo
 * @param adUnit The ad unit to request
 * @param contextData The context of the request
 * @param responseHandler the handler called on response. Responded bid can be nil.
 * Note: responseHandler is invoked on main queue
 */
- (void)loadBidForAdUnit:(CRAdUnit *)adUnit
             withContext:(CRContextData *)contextData
         responseHandler:(CRBidResponseHandler)responseHandler;

#pragma mark App bidding

/**
 * App bidding API, enrich your ad object with Criteo metadata
 * @param object The object to enrich, supports GAM and MoPub
 * @param bid The bid obtained from Criteo
 */
- (void)enrichAdObject:(id)object withBid:(CRBid *_Nullable)bid;

#pragma mark - Debug

+ (void)setVerboseLogsEnabled:(BOOL)enabled;

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
