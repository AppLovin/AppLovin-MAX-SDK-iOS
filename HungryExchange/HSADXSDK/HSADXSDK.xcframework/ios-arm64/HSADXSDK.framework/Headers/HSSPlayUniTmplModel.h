//
//  HSSPlayUniTmplModel.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/5/9.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBaseModel.h"
#import <HSADXSDK/HSSAdFormat.h>

@class HSSControlBtnModel;
@class HSSOverlayModel;
@class HSSPlayableToolTipModel;
@class HSSOverlayCtaModel;

typedef NS_ENUM(NSInteger, HSUniTmplMaterialType){
    HSUniTmplMaterialType_Video = 1,
    HSUniTmplMaterialType_Game = 2,
    HSUniTmplMaterialType_PicTxt = 3,
    HSUniTmplMaterialType_EndCard = 4,
    HSUniTmplMaterialType_Image = 5
};

NS_ASSUME_NONNULL_BEGIN

@interface HSSPlayUniTmplProgressBarModel  : HSSBaseModel
/// 是否展示进度条
@property (nonatomic, assign) BOOL is_show;
/// 进度条前景色
@property (nonatomic, copy) NSString * bar_color;
/// 进度条背景色
@property (nonatomic, copy) NSString * bar_back_color;
@end

@interface HSSPlayUniTmplCtaModel :HSSBaseModel

///  ctaType
@property (nonatomic, assign) NSInteger type;

/// icon url
@property (nonatomic, copy) NSString *icon;

/// btn_txt
@property (nonatomic, copy) NSString *btnTxt;

@end

@interface HSSPlayUniTmplImageModel :HSSBaseModel

/// type
@property (nonatomic, assign) NSInteger type;

/// url
@property (nonatomic, copy) NSString *url;

/// 控制按钮区域(跳过关闭按钮)
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

@end


@interface HSSPlayUniTmplEndCardModel :HSSBaseModel

@property (nonatomic, assign) NSInteger type;

/// icon
@property (nonatomic, copy) NSString *icon;

/// image
@property (nonatomic, copy) NSString *image;

/// image_btn
@property (nonatomic, copy) NSString *imageBtn;

/// title
@property (nonatomic, copy) NSString *title;

/// desc
@property (nonatomic, copy) NSString *desc;

/// btn_txt
@property (nonatomic, copy) NSString *btnTxt;

/// 控制按钮区域(跳过关闭按钮)
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

/// 跳转按钮
@property (nonatomic, strong) HSSOverlayCtaModel *cta;
/// 跳转按钮样式
@property (nonatomic, copy) NSString *variant;

/// 从底部开始可点区域占比; 50：从底部开始50%可以点击
@property (nonatomic, assign) NSInteger clickable_area_pct;

/// icon是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL icon_clickable;

/// text是否可点击, 0：不可点击; 1：可点击
@property (nonatomic, assign) BOOL text_clickable;

@end

@interface HSSPlayUniTmplPicModel :HSSBaseModel

///  type
@property (nonatomic, assign) NSInteger type;

/// icon url
@property (nonatomic, copy) NSString *url;

/// btn_txt
@property (nonatomic, copy) NSString *btnTxt;

@end

@interface HSSPlayUniTmplPlayModel :HSSBaseModel

/// type
@property (nonatomic, assign) NSInteger type;

/// url
@property (nonatomic, copy) NSString *url;

/// 控制按钮区域(跳过关闭按钮)
@property (nonatomic, strong) HSSControlBtnModel *control_btn;

/// 是否静音, 0：不静音，1：静音
@property (nonatomic, assign) BOOL is_muted;

/// 加载延迟时间, 0：立即加载
@property (nonatomic, assign) NSInteger load_delay_ms;

@end

@interface HSSPlayUniTmplVideoModel :HSSBaseModel

///  ctaType
@property (nonatomic, assign) NSInteger type;

/// url
@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSArray <HSSPlayUniTmplCtaModel *> *ctas;

/// 控制按钮区域(跳过关闭按钮)
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

/// 进度条配置
@property (nonatomic, strong) HSSPlayUniTmplProgressBarModel *progress_bar;

@end

@interface HSSPlayUniTmplMaterialModel :HSSBaseModel

@property (nonatomic, assign) HSUniTmplMaterialType type;

@property (nonatomic, strong) HSSPlayUniTmplVideoModel *video;

@property (nonatomic, strong) HSSPlayUniTmplPicModel *pic;

@property (nonatomic, strong) HSSPlayUniTmplPlayModel *play;

@property (nonatomic, strong) HSSPlayUniTmplEndCardModel *endcard;

@property (nonatomic, strong) HSSPlayUniTmplImageModel *image;

@end

@interface HSSPlayUniTmplSectionModel :HSSBaseModel

// section 类型 1.首段 2.中间段 3.ec段
@property (nonatomic, assign) NSInteger type;

// 延时跳过时长，秒，仅首段section && 插屏
@property (nonatomic, assign) NSInteger skipDelay;

// 激励时长，秒，仅首段section && 激励
@property (nonatomic, assign) NSInteger rewardTime;

// 延迟关闭时长，秒, 仅ec section段
@property (nonatomic, assign) NSInteger closeDelay;

// creatives
@property (nonatomic, strong) NSArray <HSSPlayUniTmplMaterialModel *>*materials;

@end


@interface HSSPlayUniTmplModel :HSSBaseModel

// 是否包含试玩，0否 1是
@property (nonatomic, assign) NSInteger isPlayable;

// 是否默认静音，0否 1是
@property (nonatomic, assign) NSInteger isMute;

// sections
@property (nonatomic, strong) NSArray <HSSPlayUniTmplSectionModel *>*sections;

@end

NS_ASSUME_NONNULL_END
