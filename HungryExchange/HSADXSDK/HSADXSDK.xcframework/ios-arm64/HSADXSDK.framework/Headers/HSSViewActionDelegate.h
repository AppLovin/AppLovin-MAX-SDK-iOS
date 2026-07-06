//
//  HSSViewResponseDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/12/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HSSItemImageModel;
@class HSSContentModel;
@class HSSCreativeExtModel;
NS_ASSUME_NONNULL_BEGIN

@protocol HSSViewActionDelegate <NSObject>

/// 关闭
-(void)actionClose:(UIView *)view params:(id _Nullable)params;

/// 更多
-(void)actionMore:(UIView *)view params:(id _Nullable)params;

/// 跳过
-(void)actionSkip:(UIView *)view params:(id _Nullable)params;

/// 静音
-(void)actionMute:(UIView *)view params:(id _Nullable)params;

/// 安装
-(void)actionInstall:(UIView *)view params:(id _Nullable)params;

/// 其他位置
-(void)actionOther:(UIView * _Nullable)view params:(id _Nullable)params;

/// 奖励时间到
-(void)actionReward:(UIView *)view params:(id _Nullable)params;

@optional
/// 试玩游戏的跳过
- (void)playableActionSkip:(UIView *)view params:(id _Nullable)params;

/// 试玩游戏的静音
- (void)playableActionMute:(nullable UIView *)view params:(id _Nullable)params fromUser:(BOOL)fromUser;

/// vast 广告的endcard的跳过
- (void)vastECActionSkip:(UIView *)view params:(id _Nullable)params;


@end

@protocol HSSViewGeneralProtocol <NSObject>

@property (nonatomic, weak) id<HSSViewActionDelegate> delegate;

@property (nonatomic, strong) HSSCreativeExtModel *extra;
@end


/// 图文协议
@protocol HSSViewImageTextProtocol <HSSViewGeneralProtocol>

/// 针对图文模版
@property (nonatomic, strong) HSSItemImageModel *imageModel;

@end


/// 结束协议
@protocol HSSViewEndCardProtocol <HSSViewGeneralProtocol>

@property (nonatomic, strong) HSSContentModel *model;

@end
NS_ASSUME_NONNULL_END
