//
//  HSSWebviewOverlayView.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/2/24.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSWebviewOverlayView : HSSBaseView

@property (nonatomic, copy) void (^upAction)(void);


@property (nonatomic, copy) void (^downAction)(void);

- (instancetype)initWithRequestUrl:(NSString *)requestUrl;

@end

NS_ASSUME_NONNULL_END
