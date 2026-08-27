//
//  HSPlayerModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSPlayerModel : NSObject

//视频的URL，本地视频/远程视频地址
@property (nonatomic, strong) NSURL *videoURL;

//播放 item
@property (nonatomic, strong) AVPlayerItem *playerItem;

//视频尺寸
@property (nonatomic,assign) CGSize presentationSize;


@end

NS_ASSUME_NONNULL_END
