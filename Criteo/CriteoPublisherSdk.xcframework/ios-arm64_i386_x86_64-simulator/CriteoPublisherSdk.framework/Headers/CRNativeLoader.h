//
//  CRNativeLoader.h
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

@class CRNativeAdUnit;
@class CRNativeAd;
@class CRBid;
@class CRContextData;
@protocol CRNativeLoaderDelegate;
@protocol CRMediaDownloader;

NS_ASSUME_NONNULL_BEGIN

/**
 * Advanced Native Ad Loader
 */
@interface CRNativeLoader : NSObject

@property(nonatomic, weak) id<CRNativeLoaderDelegate> delegate;
@property(nonatomic, strong) id<CRMediaDownloader> mediaDownloader;

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit;

/**
 * Load the native ad for standalone integration.
 *
 * Do nothing if the delegate is nil or if it doesn't implement nativeLoader:didReceiveAd:.
 */
- (void)loadAd;

/**
 * Load the native ad for standalone integration.
 *
 * Do nothing if the delegate is nil or if it doesn't implement nativeLoader:didReceiveAd:.
 *
 * @param contextData Context of the Ad to load
 */
- (void)loadAdWithContext:(CRContextData *)contextData;

/**
 * Load the native ad for In-House integration.
 *
 * If the bid is valid, you'll be notified with the native assets via the
 * nativeLoader:didReceiveAd: method of the delegate.
 *
 * Do nothing if the delegate is nil or if it doesn't implement nativeLoader:didReceiveAd:.
 *
 * @param bid to get an Ad from
 */
- (void)loadAdWithBid:(CRBid *_Nullable)bid;

@end

/**
 * All the methods of the CRNativeLoaderDelegate are invoked on main dispatch queue,
 * so it is safe to execute UI operations in the implementation.
 */
@protocol CRNativeLoaderDelegate <NSObject>

@optional

/**
 * Callback invoked when a native ad is successfully received. It is expected to display the native
 * ad.
 *
 * @param loader Native loader invoking the callback
 * @param ad native ad with the data that may be used to render it
 */
- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad;

/**
 * Callback invoked when the SDK fails to provide a native ad.
 *
 * @param loader Native loader invoking the callback
 * @param error error indicating the reason of the failure
 */
- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error;

/**
 * Callback invoked when a native ad impression is detected.
 *
 * @param loader Native loader invoking the callback
 */
- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader;

/**
 * Callback invoked when a native ad is clicked.
 *
 * @param loader Native loader invoking the callback
 */
- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader;

/**
 * Callback invoked when user clicks on an Ad or AdChoice button, opening its associated URL
 *
 * @param loader Native loader invoking the callback
 */
- (void)nativeLoaderWillLeaveApplication:(CRNativeLoader *)loader;

@end

NS_ASSUME_NONNULL_END
