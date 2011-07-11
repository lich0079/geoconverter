//
//  CLog.h
//  geoconverter
//
//  Created by lich0079 on 11-7-11.
//  Copyright 2011年 ibm. All rights reserved.
//
#ifdef DEBUG
#define CLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define CLog(format, ...)
#endif