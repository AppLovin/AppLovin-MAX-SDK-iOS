//
//  ALAdManager.m
//  DemoApp-ObjC
//
//  Created by Thomas So on 9/4/19.
//  Copyright © 2019 AppLovin Corporation. All rights reserved.
//

#import "ALAdManager.h"

@implementation ALAdManager

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)initialize
{
    
}

@end
