//
//  HSSControlInfo.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import "HSSBaseModel.h"
#import <HSADXSDK/HSSAdFormat.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ControlInfo（共用子结构）

/// 组件显示时机策略（对应服务端 show 字段）
typedef NS_ENUM(NSInteger, HSSControlShowStrategy) {
    HSSControlShowStrategyUnknown    = 0,  // 未知 / 未下发
    HSSControlShowStrategyAtStart    = 1,  // 播放开始即显示
    HSSControlShowStrategyAtSeconds  = 2,  // 播放到第 value 秒显示
    HSSControlShowStrategyAtPercent  = 3,  // 播放到 value% 时显示
    HSSControlShowStrategyBeforeEnd  = 4,  // 距播放结束 value 秒显示
};

#pragma mark - Pos 锚点位置

/// 组件相对容器的锚点位置（对应服务端 pos 字段，字符串 "1"~"5"）
typedef NS_ENUM(NSInteger, HSSControlPos) {
    HSSControlPosUnknown      = 0,
    HSSControlPosTopLeft      = 1,  // 左上：margin=距左、offset=距上
    HSSControlPosTopRight     = 2,  // 右上：margin=距右、offset=距上
    HSSControlPosBottomLeft   = 3,  // 左下：margin=距左、offset=距下
    HSSControlPosBottomRight  = 4,  // 右下：margin=距右、offset=距下
    HSSControlPosBottomCenter = 5,  // 底部居中：margin=水平偏移(0=居中,正右负左)、offset=距下
};

/// 按 pos 锚点 + margin/offset 计算组件在容器内的 frame。
///
///   - margin / offset 当前由组件层各自传入硬编码值；
///   - 后续若服务端下发 margin / offset，只需把组件里的写死值改为
///     `self.controlInfo.margin / .offset` 即可，inline 函数与调用方签名不变。
///   - pos 不识别（缺省 / 不在 1~5）时，兜底"靠左上"
///     不做隐式兜底，避免错误数据被静默吞掉。
///
/// @param pos             "1"~"5"（HSSControlPos）；缺省/非法 → 左上
/// @param componentSize   组件自身尺寸
/// @param containerSize   容器尺寸
/// @param margin          水平方向边距：1/3=距左、2/4=距右、5=水平偏移
/// @param offset          垂直方向边距：1/2=距上、3/4/5=距下
NS_INLINE CGRect HSSControlFrameForPos(NSString * _Nullable pos,
                                       CGSize componentSize,
                                       CGSize containerSize,
                                       CGFloat margin,
                                       CGFloat offset) {
    CGFloat W = containerSize.width;
    CGFloat H = containerSize.height;
    CGFloat w = componentSize.width;
    CGFloat h = componentSize.height;
    CGPoint origin = CGPointZero;
    switch ((HSSControlPos)pos.integerValue) {
        case HSSControlPosTopLeft:
            origin = CGPointMake(margin, offset);
            break;
        case HSSControlPosTopRight:
            origin = CGPointMake(W - w - margin, offset);
            break;
        case HSSControlPosBottomLeft:
            origin = CGPointMake(margin, H - h - offset);
            break;
        case HSSControlPosBottomRight:
            origin = CGPointMake(W - w - margin, H - h - offset);
            break;
        case HSSControlPosBottomCenter:
            origin = CGPointMake((W - w) * 0.5 + margin, H - h - offset);
            break;
        case HSSControlPosUnknown:
        default:
            origin = CGPointMake(margin, offset);
            break;
    }
    return (CGRect){ origin, componentSize };
}

@interface HSSControlInfo : HSSBaseModel

/// 样式标识 Key（对应组件注册表的 variant）
@property (nonatomic, copy) NSString *key;

/// 显示位置（"1"~"5"，对应 HSSControlPos；与 HSSControlFrameForPos 配套）
@property (nonatomic, copy) NSString *pos;

/// 显示策略（字符串形式，取值对应 HSSControlShowStrategy）
@property (nonatomic, copy) NSString *show;

/// 策略对应的数值
@property (nonatomic, assign) NSInteger value;

/// 合计（仅进度条时存在；对齐 ads_resp 文档 ControlInfo.Total）
/// 进度条总刻度，组件按 currentTime / total 计算填充比例
@property (nonatomic, assign) NSInteger total;

/// 组件变可见后的倒计时时长（秒）
/// 与 show/value 职责分离：value 是"何时显示"，countDown 是"显示后倒计多少秒"
/// - 0 / 未下发 → 组件无倒计时（立即可交互）
/// - N > 0     → 模板 2.0 矩形倒计时等在 mediaDidStart 起计 N 秒；show 仅控制控件可见时机（hidden→显示）
/// 字段名待服务端定稿后可能调整（预留用，下发 JSON key: "count_down"）
@property (nonatomic, assign) NSInteger countDown;

/// 通用兜底 close（立即可点，无 countDown）。
/// 适用：附属段（非首段）/ EndCard / 任何"服务端未下发 close 但仍需挂关闭入口"的场景。
/// 主体段（首段）请走 +firstSegmentFallbackCloseForAdFormat: 拿带 countDown 的兜底。
/// 默认 key=HSSInternalDefaultCloseKey（框架内部专用，服务端不下发），
/// 命中 HSSDefaultCloseComponent；value=0、countDown=0（立即可见、立即可点）。
+ (HSSControlInfo *)defaultFallbackClose;

/// 首段（主体段）兜底 close（带广告类型相关 countDown）。
/// - HSSAdFormatTypeInter  → countDown=5（插屏首段默认 5 秒后可关闭）
/// - HSSAdFormatTypeReward → countDown=30（激励首段默认 30 秒后可跳过）
/// - 其他广告类型          → countDown=0（等价于 defaultFallbackClose）
///
/// 适用：HSSVideoSegmentVC / HSSPlayableSegmentVC 等主体段 VC，在 seg.isFirstSegment==YES
/// 且 seg.controlArea.close 为 nil 时显式 pull；非首段 / EndCard 段应改用 defaultFallbackClose。
+ (HSSControlInfo *)firstSegmentFallbackCloseForAdFormat:(HSSAdFormatType)adFormat;

/// 段级 controlArea.close 字段的"严格"解析入口（不兜底）。
/// 服务端下发字典 → 用下发配置构造；缺失 / nil / 非字典 → 返回 nil。
///
/// 设计意图：把"是否需要 close 兜底、用哪种 close"的决策权交回 SegmentVC，
/// 不在 Model 层做隐式 push。调用方（HSSControlArea）若拿到 nil，
/// 由各 SegmentVC 在 mount 阶段用 ?: 显式 pull 适合自身段类型的兜底。
+ (nullable HSSControlInfo *)closeFromDictOrNil:(nullable id)dict;

/// 显示策略枚举（从 show 字符串转换）
- (HSSControlShowStrategy)showStrategy;

/// 当前媒体进度下，组件是否应展示
/// - strategy=1：始终返回 YES
/// - strategy=2：currentTime >= value 时 YES
/// - strategy=3：duration>0 && currentTime/duration*100 >= value 时 YES
/// - strategy=4：duration>0 && (duration - currentTime) <= value 时 YES
/// - 其他：默认 YES（服务端未下发策略时不阻止展示）
- (BOOL)shouldShowAtTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

@end

#pragma mark - ClickArea

@interface HSSClickArea : HSSBaseModel

/// 点击策略：
///   "1" → 全屏可点（overlay 覆盖整个 componentContainer）
///   "2" → 非全屏（按 action / value 决定具体热区）
@property (nonatomic, copy) NSString *strategy;

/// 非全屏（strategy=2）时的子模式：
///   "1" → 底部高度比例（value 为百分比，0~100）
///   "2" → 区域选择（value 为 4 位二进制位掩码，1×4 水平条带（纵向四等分））
@property (nonatomic, copy) NSString *action;

/// 与 action 配合：
///   action=1 → 底部高度比例（0~100）
///   action=2 → 四区位掩码（例：value=5 即 0b0101 → 选区1+区3 ）
@property (nonatomic, assign) NSInteger value;

/// 小卡（OverlayArea CTA 卡片）是否参与点击响应。
///
/// 本字段由 OverlayArea 组件**自行读取**并消化（通过 `context.currentSegment.clickArea.isClickMinCard` 访问），
/// 框架层只解析，不在 SegmentVC 统一应用 —— 不同 OverlayArea 组件（IconMoreView / FloatingCapsuleView /
/// VerifycardView 等）内部结构差异大（CTA button / Lottie / 文字），可点策略需组件自治。
///
///   "1"     → 小卡可点（CTA button 正常响应自身点击）
///   "0"     → 小卡不可点（点击穿透到 SegmentVC 的 clickOverlay 触发全屏点击）
///   缺省 "" → 由具体组件按自身 spec 决定默认行为
@property (nonatomic, copy) NSString *isClickMinCard;

@end

#pragma mark - AudioArea

@interface HSSAudioArea : HSSBaseModel

/// 样式标识 Key
@property (nonatomic, copy) NSString *key;

/// 显示位置
@property (nonatomic, copy) NSString *pos;

/// 是否静音
@property (nonatomic, copy) NSString *isMuted;

/// 转成通用 HSSControlInfo，供组件挂载框架按 key 统一挂载使用
- (HSSControlInfo *)toControlInfo;

@end

#pragma mark - OverlayArea

@interface HSSOverlayArea : HSSBaseModel

/// 样式标识 Key
@property (nonatomic, copy) NSString *key;

/// 显示位置
@property (nonatomic, copy) NSString *pos;

/// 显示策略
@property (nonatomic, copy) NSString *show;

/// 策略对应数值
@property (nonatomic, assign) NSInteger value;

/// 按钮颜色
@property (nonatomic, copy) NSString *btnColor;

/// 文本颜色
@property (nonatomic, copy) NSString *textColor;

/// 按钮动画样式 key（如 ec_cta_lottie_zoom / ec_cta_lottie_neon 等）
/// JSON key: "btn_animation"
@property (nonatomic, copy, nullable) NSString *btnAnimation;

/// 图片资源 key（指向具体图片资源标识）
/// JSON key: "image_key"
@property (nonatomic, copy, nullable) NSString *image_key;

/// 转成通用 HSSControlInfo，供组件挂载框架按 key 统一挂载使用
- (HSSControlInfo *)toControlInfo;

@end

#pragma mark - AdArea

@interface HSSAdArea : HSSBaseModel

/// 广告标识样式 Key
@property (nonatomic, copy) NSString *key;

/// 广告标识显示位置
@property (nonatomic, copy) NSString *pos;

/// 转成通用 HSSControlInfo，供组件挂载框架按 key 统一挂载使用
- (HSSControlInfo *)toControlInfo;

@end

#pragma mark - EndCardCta

@interface HSSEndCardCta : HSSBaseModel

/// 按钮颜色
@property (nonatomic, copy) NSString *btnColor;

/// 文字颜色
@property (nonatomic, copy) NSString *textColor;

@end

#pragma mark - NextLink（段间流转配置）

@interface HSSNextLink : HSSBaseModel

/// 是否自动进入下一段（"1" = 自动；其他/缺省 = 不自动）
@property (nonatomic, copy) NSString *autoNext;

/// 流转策略（按 N 秒 / N% 自动切段；"" = 仅依赖 autoNext + 媒体结束）
@property (nonatomic, copy) NSString *strategy;

/// 策略对应数值
@property (nonatomic, assign) NSInteger value;

/// 关闭是否触发下一段（"1" = 切下段；其他/缺省 = 关闭整体广告）
@property (nonatomic, copy) NSString *closeNext;

/// 段间流转的兜底默认配置（数据契约层集中默认值）。
/// 业务约束：
///   - 用户点击跳过/关闭按钮 → 切下段；最后一段关广告
///   - 视频播放完成 → 自动切下段；最后一段关广告
/// 默认值规则：
///   closeNext = isLast ? "0" : "1"   // 最后一段关广告，否则切下段
///   autoNext  = "1"                  // 视频播完即自动切（业务侧需要）
///   strategy  = ""                   // 不下发中途自动切策略
///   value     = 0
+ (HSSNextLink *)defaultForSegmentAtIndex:(NSInteger)index totalCount:(NSInteger)total;

@end

NS_ASSUME_NONNULL_END
