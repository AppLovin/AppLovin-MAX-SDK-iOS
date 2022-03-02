//
//  CRMediaView.h
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

#import <Foundation/Foundation.h>

@class UIImage;
@class CRMediaContent;

/**
 * A view that can hold and display a CRMediaContent.
 *
 * The CRMediaView takes care of loading the necessary ressources if needed.
 */
@interface CRMediaView : UIView

/**
 * Placeholder to display while the media content is loading or in case of error.
 */
@property(strong, nonatomic, nullable) UIImage *placeholder;

/**
 * New media content to load in this view.
 */
@property(strong, nonatomic, nullable) CRMediaContent *mediaContent;

@end
