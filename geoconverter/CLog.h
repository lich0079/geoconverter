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

#define  a_convert  @"convert"
#define  a_searchyahoo  @"s_yahoo"
#define  a_searchios5  @"s_ios5"
#define  a_longpress @"long"
#define  a_tap  @"tap"
#define  a_drawline @"drawline"
#define  a_degree  @"degree"
#define  a_help    @"help"
#define  a_locationinfo    @"locationinfo"
#define  a_addbutton    @"addbutton"
#define  a_iad  @"iad"
#define  a_admob  @"admob"
#define  a_noad   @"noad"
#define  a_hasad   @"hasad"