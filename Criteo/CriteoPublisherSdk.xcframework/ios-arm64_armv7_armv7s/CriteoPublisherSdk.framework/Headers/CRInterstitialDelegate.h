//
//  CRInterstitialDelegate.h
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

#ifndef CRInterstitialDelegate_h
#define CRInterstitialDelegate_h

@class CRInterstitial;

@protocol CRInterstitialDelegate <NSObject>
@optional

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial;
- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error;

- (void)interstitialWillAppear:(CRInterstitial *)interstitial;
- (void)interstitialDidAppear:(CRInterstitial *)interstitial;

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial;
- (void)interstitialDidDisappear:(CRInterstitial *)interstitial;

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial;
- (void)interstitialWasClicked:(CRInterstitial *)interstitial;

@end

#endif /* CRInterstitialDelegate_h */
