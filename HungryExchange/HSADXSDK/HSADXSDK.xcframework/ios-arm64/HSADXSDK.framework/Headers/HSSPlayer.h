//
//  HSPlayer.h
//  HSADXSDK
//
//  Created by admin on 2024/11/20.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <HSADXSDK/HSSPlayerModel.h>

NS_ASSUME_NONNULL_BEGIN

// 播放器的几种状态
typedef NS_ENUM(NSInteger, HSSPlayerState) {
    HSSPlayerStateFailed = 0,        // 播放失败
    HSSPlayerStateBuffering = 1,     // 缓冲中
    HSSPlayerStatePlaying = 2,       // 播放中
    HSSPlayerStateStopped = 3,       //暂停播放
    HSSPlayerStateFinished = 4,      //完成播放
    HSSPlayerStatePause = 5,         // 打断播放,eg:后台
};

typedef NS_ENUM(NSInteger, HSSPlayerLayerGravity) {
    HSSPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    HSSPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    HSSPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};

@class HSSPlayer;
@protocol HSSPlayerDelegate <NSObject>

@optional

//播放失败的代理方法
-(void)hssplayerFailedPlay:(HSSPlayer *)hsplayer HSSPlayerStatus:(HSSPlayerState)state error:(nullable NSError *)error;

//准备播放的代理方法
-(void)hssplayerReadyToPlay:(HSSPlayer *)hsplayer HSSPlayerStatus:(HSSPlayerState)state;

//播放器已经拿到视频的尺寸大小
-(void)hssplayerGotVideoSize:(HSSPlayer *)hsplayer videoSize:(CGSize )presentationSize;

//首帧真正上屏（AVPlayerLayer.readyForDisplay = YES）—— real_play 事件源
-(void)hssplayerReadyForDisplay:(HSSPlayer *)hsplayer;

//播放真正推进过阈值时间点（boundary）—— time_reached 事件源，证明非"起播即卡死"
-(void)hssplayerDidReachPlaybackTime:(HSSPlayer *)hsplayer;

//播放完毕的代理方法
-(void)hssplayerFinishedPlay:(HSSPlayer *)hsplayer;

//播放器播放进度
-(void)hssplayerPlay:(HSSPlayer *)hsplayer progress:(float)progress;

// 进入后台
-(void)hssplayerBackgroundPlay:(HSSPlayer *)hsplayer HSSPlayerStatus:(HSSPlayerState)state;

// 进入前台
-(void)hssplayerForegroundPlay:(HSSPlayer *)hsplayer HSSPlayerStatus:(HSSPlayerState)state;

@end

@interface HSSPlayer : UIView

@property (nonatomic, weak) id<HSSPlayerDelegate> delegate;

/// 播放速率
@property (nonatomic, assign) CGFloat rate;

//播放器player
@property (nonatomic, strong) AVPlayer *player;
 
/// adx底版模版使用  (双视频video使用 判断是否是第一个video)
@property (nonatomic, assign) BOOL isFirst;

/// 统一模版使用  section
@property (nonatomic, assign) NSInteger section;

///  统一模版使用 是否第一个视频
@property (nonatomic, assign) BOOL isFisrtVideo;

/// 是否静音
@property (nonatomic, assign) BOOL  muted;

/// 播放器音量
@property (nonatomic, assign, readonly) CGFloat volume;

/// 填充模式
@property (nonatomic, assign) HSSPlayerLayerGravity playerLayerGravity;

/// 播放器对应 model
@property (nonatomic, strong) HSSPlayerModel *playerModel;

/// 播放器的super layer 用于OM 跟踪
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign) BOOL innerWebVCPresented;

/// 返回实例播放哦
/// @param playerModel 播放 model
-(instancetype)initPlayerModel:(HSSPlayerModel *)playerModel;

/// 返回实例播放哦
/// @param playerModel 播放 model
+(instancetype)playerWithModel:(HSSPlayerModel *)playerModel;

/// 提前创建 AVPlayer + 开始 buffer（不触发 play）
///
/// 设计动机：
///   默认行为下 AVPlayer 在第一次 -play 被调时才创建（内部 creatHSPlayerAndReadyToPlay），
///   随之 AVPlayerItem 进入 Unknown → ReadyToPlay 需要额外 200~500ms 才能出首帧。
///   对广告这种"present 动画 + 首帧尽快可见"的场景，可在 viewDidLoad 阶段预先调 prepareToPlay，
///   让 AVPlayer 在 present 动画期间完成 buffer，到 viewDidAppear 调 -play 时首帧立即可出。
///
/// 幂等：重复调用无副作用（内部 isInitPlayer 守卫）
- (void)prepareToPlay;

/// 播放
- (void)play;

/// 暂停
- (void)pause;

/// player处理续播
- (void)hss_playerHandleResumeEvent;

/// player处理停播
- (void)hss_playerHandlePauseEvent;

/// 重置播放器
- (void)resetHSPlayer;

/// 获取当前播放时间
- (double)currentTime;

/// 获取视频时长
- (double)duration;

/// 获取视频时长 (不判断status)
- (double)playerDuration;

/// 续播or暂停， 返回值表示当前是否为暂停状态
- (BOOL)resumeOrPauseAndCurrentIsPaused;

- (UIImage *)captureCurrentFrame;

/// 获取视频的最后一帧
- (UIImage *)captureLastFrame;

@end

NS_ASSUME_NONNULL_END
