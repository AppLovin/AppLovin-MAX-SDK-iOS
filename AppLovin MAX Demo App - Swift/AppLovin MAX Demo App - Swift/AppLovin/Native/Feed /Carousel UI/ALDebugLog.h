//
//  ALDebugLog.h
//  iOS Test App NG
//
//  Created by Matt Szaro on 5/29/15.
//  Copyright (c) 2015 AppLovin. All rights reserved.
//

#ifndef iOS_Test_App_NG_ALDebugLog_h
#define iOS_Test_App_NG_ALDebugLog_h

#ifdef DEBUG
    #define ALLog(str, ...) NSLog(str, ##__VA_ARGS__)
#else
    #define ALLog(str, ...)
#endif

#endif
