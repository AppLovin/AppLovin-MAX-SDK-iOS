//
//  HSSVideoPlayerVC.h
//  HSADXSDK
//
//  Created by admin on 2024/12/2.
//

#import "HSSBaseViewController.h"
#import <HSADXSDK/HSSVideoPlayerProtocol.h>
#import <HSADXSDK/HSSADXBottomProgressView.h>
#import <WebKit/WebKit.h>
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSOMIDSessionInteractor.h>

@class HSSPlayer;
@class HSSItemVideoModel;
@class HSSPlayableModel;
@class HSSPlayUniTmplModel;
@class HSSPlayUniTmplMaterialModel;
@class HSSAdxUniTmplModel;
@class HSSAdxUniTmplMaterialModel;
@class HSSStreamVideoLoader;
@class HSSStreamMaterialLoader;

// 广告物料用户设置的禁止状态（优先级高于物料自身内部下发的初始禁音值)
typedef NS_ENUM(NSInteger, HSSAdMuteUserStatus) {
    HSSAdMuteUserStatus_Unknown = 0,   // 用户未主动设置
    HSSAdMuteUserStatus_Mute = 1,       // 用户设置成禁音
    HSSAdMuteUserStatus_UnMute = 2      // 用户设置成非禁音
};

NS_ASSUME_NONNULL_BEGIN

@interface HSSVideoPlayerVC : HSSBaseViewController<HSSVideoPlayerProtocol>

/// 播放器
@property (nonatomic, strong, readonly) HSSPlayer *player;

/// 预加载的 MaterialLoader 映射（URL -> MaterialLoader），通过 url 取 materialLoader.videoPreloader 获取 playerItem
@property (nonatomic, strong, nullable) NSDictionary<NSString *, HSSStreamMaterialLoader *> *preloadedMaterialLoaders;

@property (nonatomic, strong) WKWebView *webView;

/// 设置静音
@property (nonatomic, assign) BOOL mute;

/// 广告物料用户设置的禁止状态（优先级高于物料自身内部下发的初始禁音值)
@property (nonatomic, assign) HSSAdMuteUserStatus muteUserStatus;

/// vast
@property (nonatomic, strong) HSSItemVideoModel *adVideoModel;

/// playable
@property (nonatomic, strong) HSSPlayableModel *playableModel;

/// uniTmpl
//@property (nonatomic, strong) HSSPlayUniTmplModel *uniTmplModel;

/// adx  uniTmpl
@property (nonatomic, strong) HSSAdxUniTmplModel *adxUniTmplModel;

/// 当前播放视频的原始URL（用于埋点统计）
@property (nonatomic, copy, readonly) NSString *originalVideoUrl;

/// PageView 上报相关（视频尺寸延迟获取）
@property (nonatomic, assign) NSInteger pendingVideoSource;      // 待上报的视频来源（1=Native, 2=VAST）
@property (nonatomic, copy) NSString *pendingVideoUrl;           // 待上报的视频 URL
@property (nonatomic, assign) BOOL hasPendingVideoPageView;      // 是否有待上报的视频 PageView
@property (nonatomic, strong, readonly) HSSPlayUniTmplMaterialModel *uniTmplMaterialModel;


// 双视频video第二个视频展示的时候事件
@property (nonatomic, copy) void (^adDoubleSecondVideoShowBlock)(HSSCreativeItemModel *creativeAdmodel);

// 双视频video第二个视频点击的时候事件
@property (nonatomic, copy) void (^adDoubleSecondVideoClickBlock)(HSSCreativeItemModel *creativeAdmodel);

/// 消失
@property (nonatomic, copy) void (^ dismissCompletion)(id);

/// 点击
@property (nonatomic, copy) void (^ clickAdCompletion)(id);

/// 获得奖励
@property (nonatomic, copy) void (^ rewardAdCompletion)(void);

// 视频开始播放
@property (nonatomic, copy) void (^ adVideoPlayCompletion)(NSDictionary * _Nullable videoPlayInfo);

// 视频帧尺寸已解出（adx_sdk_video_size_ready）
@property (nonatomic, copy) void (^ adVideoSizeReadyCompletion)(NSDictionary * _Nullable videoPlayInfo);

// 首帧真正上屏（adx_sdk_video_real_play）：黑屏率分子
@property (nonatomic, copy) void (^ adVideoRealPlayCompletion)(NSDictionary * _Nullable videoPlayInfo);

// 播放真正推进过阈值（adx_sdk_video_time_reached）：区分有音无画 vs 起播卡死
@property (nonatomic, copy) void (^ adVideoTimeReachedCompletion)(NSDictionary * _Nullable videoPlayInfo);

// 视频播放失败（adx_sdk_video_play_failed）：videoPlayInfo 含 video_url / video_duration，由 HSSPlayer 层透出
@property (nonatomic, copy) void (^ adVideoPlayFailed)(NSDictionary * _Nullable videoPlayInfo, NSError *error);

// 视频播放结束
@property (nonatomic, copy) void (^ adVideoEndCompletion)(NSDictionary * _Nullable videoEndInfo);

// 视频播放进度
@property (nonatomic, copy) void (^ adVideoPlayProgressCompletion)(NSInteger);

// 试玩游戏通用事件埋点方法
@property (nonatomic, copy) void (^ playableAdEvent)(NSString *);

// vast的endcard 的点击回调
@property (nonatomic, copy) void (^vastEndCardClickAdBlock)(id);

// 试玩游戏 试玩广告，试玩达到目标进度上报
@property (nonatomic, copy) void (^ playableAdProgress)(NSString *);

@property (nonatomic, strong) HSSADXBottomProgressView *progressView;

@property (nonatomic, assign) NSInteger material_type;

@property (nonatomic, assign) NSInteger webLoadTime;

// 给统一模版使用 点击的时候赋值当前点击的section
@property (nonatomic, copy) NSString *sectionPos;

/// 展示的广告是否是离线广告
@property (nonatomic, assign) BOOL isOfflineAd;

/// 展示的广告是否是双视频video
@property (nonatomic, assign) BOOL isDoubleVideo;

/// 展示的广告是否是Local广告
@property (nonatomic, assign) BOOL isLocalAd;

// omid监测实例
@property (nonatomic, strong) HSSOMIDSessionInteractor *omidSession;

/// 关闭广告
-(void)closeAd;

/// 点击跳过
-(void)clickSkip;

/**
 * 设置播放器静音状态
 * @param mute  YES: 静音  NO:非静音
 */
-(void)setVideoMute:(BOOL)mute;

- (void)destroyWebview;

- (void)destroyPlayer;

- (void)startPlayGameTimer;

/// js调用的跳转逻辑, 子类实现
- (void)openByJS;

/// 根据统一模板物料类型， 判断该物料的禁音状态
- (BOOL)uniTmplMuteWithMaterialModel:(HSSPlayUniTmplMaterialModel *)materialModel;

/// 根据adx 统一模板物料类型， 判断该物料的禁音状态
- (BOOL)adxUniTmplMuteMaterialModel:(HSSAdxUniTmplMaterialModel *)materialModel;

- (void)configureAdxPlayerUrl:(NSString *)playerUrl section:(NSInteger)section material:(HSSAdxUniTmplMaterialModel *)material;

- (void)configurePlayerModelForVideo2:(HSSCreativeItemModel *)creative;

#pragma mark - 视频播放时长追踪

/// 停止视频播放时长计时（供子类在 skip 时调用）
- (void)stopPlayDurationTimer;

/// 构建视频开始播放信息（供子类调用）
/// @param player 播放器对象
- (NSDictionary *)buildVideoPlayInfo:(HSSPlayer *)player;

/// 构建视频结束信息（供子类调用）
/// @param endType 结束类型："skip" 或 "playend"
/// @param player 播放器对象
- (NSDictionary *)buildVideoEndInfo:(NSString *)endType player:(HSSPlayer *)player;

/// 判断当前是否正在播放视频（供子类调用）
/// @return YES: 正在播放视频；NO: 未播放视频或视频已结束
- (BOOL)isCurrentlyPlayingVideo;

#pragma mark - 判断是否存在播放器，外界要获取播放器不能直接调用getter，否则会触发懒加载创建player
- (BOOL)hasPlayer;

@end

NS_ASSUME_NONNULL_END
