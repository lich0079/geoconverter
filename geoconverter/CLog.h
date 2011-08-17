//
//  CLog.h
//  geoconverter
//
//  Created by lich0079 on 11-7-11.
//  Copyright 2011年 ibm. All rights reserved.
//
#ifdef DEBUG
#define CLog(format, ...) NSLog(format, ## __VA_ARGS__)
#define CLogc  CLog(@"%s", __FUNCTION__)
#else
#define CLog(format, ...)
#define CLogc
#endif

#define isIPad  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
