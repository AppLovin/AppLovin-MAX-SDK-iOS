//
//  HSSPlayableModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/3/5.
//

#import <HSADXSDK/HSADXSDK.h>
#import <HSADXSDK/HSSAdFormat.h>
#import "HSSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSSPlayableToolTipModel : HSSBaseModel
@property (nonatomic, assign) BOOL is_show;
/// 显示文案
@property (nonatomic, copy) NSString *text;
/// 文案的颜色
@property (nonatomic, copy) NSString *text_color;
/// 背景颜色
@property (nonatomic, copy) NSString *background;
/// 最大显示次数
@property (nonatomic, assign) NSInteger max_times_shown;
@end

@interface HSSControlBtnModel : HSSBaseModel
/// 按钮样式， NextRecord, TwoArrows, Close
@property (nonatomic, copy) NSString *style;
/// 按钮大小
@property (nonatomic, assign) NSInteger size;
/// 按钮旁边的文案
@property (nonatomic, copy) NSString *tipText;
/// 延迟显示时间
@property (nonatomic, assign) NSInteger show_delay_ms;
/// 位置 top-left：上左, top-center: 上中, top-right: 上右
@property (nonatomic, copy) NSString *position;
@end

@interface HSSOverlayCtaModel : HSSBaseModel
/// 显示文案
@property (nonatomic, copy) NSString *text;
/// 背景颜色
@property (nonatomic, copy) NSString *background_color;
/// 文字颜色
@property (nonatomic, copy) NSString *text_color;
/// 背景图片
@property (nonatomic, copy) NSString *background_icon;
@end

@interface HSSOverlayModel : HSSBaseModel
/// 按钮样式
@property (nonatomic, copy) NSString *variant;
/// 延迟显示时间
@property (nonatomic, assign) NSInteger show_delay_ms;
/// 位置， down-left：上左； down-center: 上中； down-right: 上右
@property (nonatomic, assign) NSInteger position;
/// 按钮Icon
@property (nonatomic, copy) NSString *icon;
/// overlay上面的按钮配置
@property (nonatomic, strong) HSSOverlayCtaModel *cta;
@end

@interface HSSPromptCtaModel : HSSBaseModel

///  prompt type
@property (nonatomic, assign) HSSPlayableAdCtaType ctaType;

/// icon url
@property (nonatomic, copy) NSString *icon;

/// desc
@property (nonatomic, copy) NSString *desc;

@end

@interface HSSPromptModel : HSSBaseModel

/// 地址url
@property (nonatomic, copy) NSString *url;

///  prompt type
@property (nonatomic, assign) HSSPlayableAdPromptType promptType;

/// 地址url
@property (nonatomic, strong) NSArray <HSSPromptCtaModel *> *ctas;

/// 控制按钮区域
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

/// 屏幕下面区域
@property (nonatomic, strong) HSSOverlayModel *overlay;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// 是否静音, 0：不静音，1：静音
@property (nonatomic, assign) BOOL is_muted;

/// 取消静音延迟时间
@property (nonatomic, assign) NSInteger unmute_delay_ms;

/// 提示框
@property (nonatomic, strong) HSSPlayableToolTipModel *tooltip;

@end


@interface HSSGameModel : HSSBaseModel

/// 地址url
@property (nonatomic, copy) NSString *url;

///  game type
@property (nonatomic, assign) HSSPlayableAdGameType gameType;

/// 控制按钮区域
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

/// 从底部开始可点区域占比, 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// 是否静音, 0：不静音，1：静音
@property (nonatomic, assign) BOOL is_muted;

/// 取消静音延迟时间
@property (nonatomic, assign) NSInteger unmute_delay_ms;

/// 倒计时毫秒, 小于等于0时不显示
@property (nonatomic, assign) NSInteger countdown_time_ms;

/// 加载延迟时间, 0：立即加载
@property (nonatomic, assign) NSInteger load_delay_ms;

/// 是否马上标记, 0：下载完成在标记; 1：立即标记为就绪
@property (nonatomic, assign) NSInteger mark_ready_immediately;

@end

@interface HSSEndcardModel : HSSBaseModel

/// title
@property (nonatomic, copy) NSString *title;

/// icon
@property (nonatomic, copy) NSString *icon;

/// image
@property (nonatomic, copy) NSString *image;

/// button image
@property (nonatomic, copy) NSString *imageBtn;

/// desc
@property (nonatomic, copy) NSString *desc;

/// btn_txt
@property (nonatomic, copy) NSString *btnTxt;

///  endcard  type
@property (nonatomic, assign) HSSPlayableAdEndcardType endcardType;

/// 控制按钮区域
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

@property (nonatomic, strong) HSSOverlayCtaModel *cta;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// icon是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL icon_clickable;

/// text是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL text_clickable;

@end

@interface HSSPlayableModel : HSSBaseModel

@property (nonatomic, strong) HSSPromptModel *prompt;

@property (nonatomic, strong) HSSGameModel *game;

@property (nonatomic, strong) HSSEndcardModel *endcard;

@property (nonatomic, strong) NSDictionary *ext;

// 游戏是否显示跳过按钮， 0: false 1: true
@property (nonatomic, assign) NSInteger skipEnable;

// 游戏显示跳过按钮的延迟时间
@property (nonatomic, assign) NSInteger skipDelay;

// 游戏是否有倒计时（即显示倒计时组件） 0: false 1: true
@property (nonatomic, assign) NSInteger countdownEnable;

// 游戏倒计时时长
@property (nonatomic, assign) NSInteger countdownLimit;

// 游戏是否显示音量控制按钮 0: false 1: true
@property (nonatomic, assign) NSInteger volEnable;

// 游戏音量控制默认：0默认开启声音 1默认静音
@property (nonatomic, assign) NSInteger volDefault;

//endcard 关闭按钮延迟
@property (nonatomic, assign) NSInteger closeDelay;

@property (nonatomic, assign) HSSPlayableAdTmplType tmplType;

// skip Icon
@property (nonatomic, copy) NSString *skipIcon;

// countdown Icon
@property (nonatomic, copy) NSString *countdownIcon;

// vol Active icon
@property (nonatomic, copy) NSString *volActiveIcon;

// vol mute icon
@property (nonatomic, copy) NSString *volMuteIcon;

/// 试玩模版编号
@property (nonatomic, assign) NSInteger ui_ver;

- (BOOL)isValidMraid;

@end

NS_ASSUME_NONNULL_END

