/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString *, id> HSSJsonDictionary;
@compatibility_alias JsonDictionary HSSJsonDictionary;

typedef NSMutableDictionary<NSString *, id> HSSMutableJsonDictionary;
@compatibility_alias MutableJsonDictionary HSSMutableJsonDictionary;

typedef NSDictionary<NSString *, NSString *> HSSStringDictionary;
typedef NSMutableDictionary<NSString *, NSString *> HSSMutableStringDictionary;

FOUNDATION_EXPORT const NSTimeInterval HSSAdPrefetchTime;

FOUNDATION_EXPORT NSString * const HSS_DOMAIN_KEY;
FOUNDATION_EXPORT NSString * const HSS_TRANSACTION_STATE_KEY;
FOUNDATION_EXPORT NSString * const HSS_TRACKING_URL_TEMPLATE;
FOUNDATION_EXPORT NSString * const HSS_ORIGINAL_ADUNIT_KEY;
FOUNDATION_EXPORT NSString * const HSS_PRECACHE_CONFIGURATION_KEY;

FOUNDATION_EXPORT NSString * const HSS_FETCH_DEMAND_RESULT_KEY;

typedef NS_ENUM(NSInteger, HSSLocationSourceValues) {
    HSSLocationSourceValuesGPS NS_SWIFT_NAME(GPS) = 1,                              //From Location Service
    HSSLocationSourceValuesIPAddress NS_SWIFT_NAME(IPAddress) = 2,                  //Unused by SDK
    HSSLocationSourceValuesUserRegistration NS_SWIFT_NAME(UserRegistration) = 3     //Supplied by Publisher
};

//MARK: Accessibility
@interface HSSAccesibility : NSObject

//Main close button that appears on Interstitials & Clickthrough Browsers
@property (class, readonly) NSString *CloseButtonIdentifier;
@property (class, readonly) NSString *CloseButtonLabel;

//Secondary close button that only appears on the bottom bar of Clickthrough Browsers
@property (class, readonly) NSString *CloseButtonClickThroughBrowserIdentifier;
@property (class, readonly) NSString *CloseButtonClickThroughBrowserLabel;

@property (class, readonly) NSString *WebViewLabel;

@property (class, readonly) NSString *VideoAdView;

@property (class, readonly) NSString *BannerView;

@end

//MARK: MRAID
typedef NSString * HSSMRAIDState NS_TYPED_ENUM;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateNotEnabled;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateDefault;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateExpanded;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateHidden;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateLoading;
FOUNDATION_EXPORT HSSMRAIDState const HSSMRAIDStateResized;


//MARK: Tracking Supression Detection Strings
typedef NSString * HSSTrackingPattern NS_TYPED_ENUM;
FOUNDATION_EXPORT HSSTrackingPattern const HSSTrackingPatternRI;
FOUNDATION_EXPORT HSSTrackingPattern const HSSTrackingPatternRC;
FOUNDATION_EXPORT HSSTrackingPattern const HSSTrackingPatternRDF;
FOUNDATION_EXPORT HSSTrackingPattern const HSSTrackingPatternRR;
FOUNDATION_EXPORT HSSTrackingPattern const HSSTrackingPatternBO;


//MARK: Query String Parameters
typedef NSString * HSSParameterKeys NS_TYPED_ENUM;
FOUNDATION_EXPORT HSSParameterKeys const HSSParameterKeysAPP_STORE_URL;
FOUNDATION_EXPORT HSSParameterKeys const HSSParameterKeysOPEN_RTB;

//MARK: PBMLocationParamKeys
NS_SWIFT_NAME(LocationParamKeys)
@interface HSSLocationParamKeys : NSObject

@property (class, readonly) NSString *Latitude                          NS_SWIFT_NAME(Latitude);
@property (class, readonly) NSString *Longitude                         NS_SWIFT_NAME(Longitude);
@property (class, readonly) NSString *Country                           NS_SWIFT_NAME(Country);
@property (class, readonly) NSString *City                              NS_SWIFT_NAME(City);
@property (class, readonly) NSString *State                             NS_SWIFT_NAME(State);
@property (class, readonly) NSString *Zip                               NS_SWIFT_NAME(Zip);
@property (class, readonly) NSString *LocationSource                    NS_SWIFT_NAME(LocationSource);

@end


//MARK: JSON Parse Keys
//TODO: Change Name
NS_SWIFT_NAME(ParseKey)
@interface HSSParseKey : NSObject

@property (class, readonly) NSString *ADUNIT                            NS_SWIFT_NAME(ADUNIT);
@property (class, readonly) NSString *HEIGHT                            NS_SWIFT_NAME(HEIGHT);
@property (class, readonly) NSString *WIDTH                             NS_SWIFT_NAME(WIDTH);
@property (class, readonly) NSString *HTML                              NS_SWIFT_NAME(HTML);
@property (class, readonly) NSString *IMAGE                             NS_SWIFT_NAME(IMAGE);
@property (class, readonly) NSString *NETWORK_UID                       NS_SWIFT_NAME(NETWORK_UID);
@property (class, readonly) NSString *REVENUE                           NS_SWIFT_NAME(REVENUE);
@property (class, readonly) NSString *SSM_TYPE                          NS_SWIFT_NAME(SSM_TYPE);

@end


//MARK: PBMAutoRefresh
@interface HSSAutoRefresh : NSObject

@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_DEFAULT   NS_SWIFT_NAME(AUTO_REFRESH_DELAY_DEFAULT);
@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_MIN       NS_SWIFT_NAME(AUTO_REFRESH_DELAY_MIN);
@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_MAX       NS_SWIFT_NAME(AUTO_REFRESH_DELAY_MAX);

@end


//MARK: Other Time Intervals
@interface HSSTimeInterval : NSObject

@property (class, readonly) NSTimeInterval VAST_LOADER_TIMEOUT          NS_SWIFT_NAME(VAST_LOADER_TIMEOUT);
@property (class, readonly) NSTimeInterval AD_CLICKED_ALLOWED_INTERVAL  NS_SWIFT_NAME(AD_CLICKED_ALLOWED_INTERVAL);
@property (class, readonly) NSTimeInterval CONNECTION_TIMEOUT_DEFAULT   NS_SWIFT_NAME(CONNECTION_TIMEOUT_DEFAULT);
@property (class, readonly) NSTimeInterval CLOSE_DELAY_MIN              NS_SWIFT_NAME(CLOSE_DELAY_MIN);
@property (class, readonly) NSTimeInterval CLOSE_DELAY_MAX              NS_SWIFT_NAME(CLOSE_DELAY_MAX);
@property (class, readonly) NSTimeInterval FIRE_AND_FORGET_TIMEOUT      NS_SWIFT_NAME(FIRE_AND_FORGET_TIMEOUT);

@end


@interface HSSVideoConstants : NSObject

@property (class, readonly) NSInteger VIDEO_TIMESCALE                   NS_SWIFT_NAME(VIDEO_TIMESCALE);

@end


//MARK: PBMGeoLocationConstants
NS_SWIFT_NAME(GeoLocationConstants)
@interface HSSGeoLocationConstants : NSObject

@property (class, readonly) double DISTANCE_FILTER                      NS_SWIFT_NAME(DISTANCE_FILTER);

@end


//MARK: PBMConstants
@interface HSSConstants : NSObject

@property (class, readonly) NSArray <NSString *> *supportedVideoMimeTypes           NS_SWIFT_NAME(supportedVideoMimeTypes);
@property (class, readonly) NSArray <NSString *> *urlSchemesForAppStoreAndITunes    NS_SWIFT_NAME(urlSchemesForAppStoreAndITunes);
@property (class, readonly) NSArray <NSString *> *urlSchemesNotSupportedOnSimulator NS_SWIFT_NAME(urlSchemesNotSupportedOnSimulator);
@property (class, readonly) NSArray <NSString *> *urlSchemesNotSupportedOnClickthroughBrowser NS_SWIFT_NAME(urlSchemesNotSupportedOnClickthroughBrowser);
@property (class, readonly) NSNumber *BUTTON_AREA_DEFAULT                           NS_SWIFT_NAME(BUTTON_AREA_DEFAULT);
@property (class, readonly) NSNumber *SKIP_DELAY_DEFAULT                            NS_SWIFT_NAME(SKIP_DELAY_DEFAULT);
@property (class, readonly) NSNumber *buttonConstraintConstant                      NS_SWIFT_NAME(buttonConstraintConstant);

@end

@interface HSSServerEndpoints : NSObject

@property (class, readonly) NSString *status
    NS_SWIFT_NAME(status);

@end


NS_ASSUME_NONNULL_END
