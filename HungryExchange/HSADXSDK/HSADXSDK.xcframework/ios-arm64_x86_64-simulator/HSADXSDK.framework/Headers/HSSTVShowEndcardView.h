//
//  HSSTVShowEndcardView.h
//  HSADXSDK
//
//  Created by biyingquan on 2026/2/3.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseView.h"
#import <HSADXSDK/HSSAdComponentProtocol.h>

@class HSSContentModel;

NS_ASSUME_NONNULL_BEGIN

/// TV-Show 风格 EndCard：视频帧缩放过渡 + icon/title/desc/CTA 多场景布局。
///
/// 模板 2.0 实现 `HSSAdComponentProtocol`：
///   - `+componentKeys` → `@[@"ec_fallback_tmpl_1"]`（对齐 ec_fallback_tmpl 字段：1=视频截图样式）
///   - 由 `HSSEndCardSegmentVC.styleKey == "ec_fallback_tmpl_1"` 时由 RenderEngine 自动挂载
///   - `configureWithControlInfo:context:` 内部从 `HSSRenderContext` 拼装 `HSSContentModel`
///   - 1.0 老路径仍可通过外部 `setModel:` 直接使用，零回归
@interface HSSTVShowEndcardView : HSSBaseView <HSSAdComponentProtocol>

@property (nonatomic, strong) HSSContentModel *model;

@end

NS_ASSUME_NONNULL_END
