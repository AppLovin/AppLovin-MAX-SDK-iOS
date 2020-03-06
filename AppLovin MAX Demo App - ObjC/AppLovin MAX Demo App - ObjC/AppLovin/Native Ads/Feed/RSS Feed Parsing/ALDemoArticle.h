//
//  ALDemoArticle.h
//  iOS-SDK-Demo
//
//  Created by Thomas So on 11/12/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALDemoArticle : NSObject

@property (nonatomic,   copy) NSString *title;
@property (nonatomic,   copy) NSString *pubDate;
@property (nonatomic,   copy) NSString *creator;
@property (nonatomic,   copy) NSString *articleDescription;
@property (nonatomic, strong) NSURL    *link;

@property (nonatomic, assign) BOOL isAd;

@end

NS_ASSUME_NONNULL_END
