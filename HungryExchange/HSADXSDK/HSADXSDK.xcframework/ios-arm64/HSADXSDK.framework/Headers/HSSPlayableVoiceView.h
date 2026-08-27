//
//  HSSPlayableVoiceView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/3/8.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN
// 试玩游戏的静音按钮view
// 同时承担模板 2.0 新架构的 audio 组件职责（type=audio, key=default）
@interface HSSPlayableVoiceView : HSSBaseView <HSSAdComponentProtocol>

- (void)setVoiceOnUrl:(NSString *)onUrl offUrl:(NSString *)offUrl volDefault:(NSInteger)volDefault;

@end

NS_ASSUME_NONNULL_END
