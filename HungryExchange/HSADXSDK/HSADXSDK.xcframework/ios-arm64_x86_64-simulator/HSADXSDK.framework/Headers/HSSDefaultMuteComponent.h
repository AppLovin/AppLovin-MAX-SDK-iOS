//
//  HSSDefaultMuteComponent.h
//  HSADXSDK
//
//  Created by biyingquan
//
//  默认静音 / 取消静音切换组件（模板 2.0）。
//
//  组件内只有一个 muteBtn：
//    - Normal  状态展示 hss_sound_on  图标（当前未静音）
//    - Selected 状态展示 hss_sound_off 图标（当前已静音）
//    - 圆底背景 hss_circle_icon_countdown
//
//  数据流：
//    点击 → 切换 selected → 同步到 context.currentMedia.setMuted: + context.muteUserStatus
//          → 沿 UIResponder 链发 hss_muteChanged: → 段 VC / EventHandler 做 OMID volumeChange + 埋点
//

#import "HSSBaseComponentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSDefaultMuteComponent : HSSBaseComponentView

@end

NS_ASSUME_NONNULL_END
