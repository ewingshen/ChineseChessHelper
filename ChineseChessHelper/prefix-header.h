//
//  prefix-header.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#ifndef prefix_header_h
#define prefix_header_h

#ifdef __OBJC__

#import "Masonry.h"
#import "KKAdHelper.h"
#import "NSString+Utils.h"
#import "KKStoreKitHelper.h"
#import "NSArray+Utils.h"
//#define LABEL_FONT(fontSize) [UIFont fontWithName:@"yuweij" size:fontSize]
#define LABEL_FONT(fontSize) [UIFont systemFontOfSize:fontSize]
#define AD_HEIGHT  ([KKStoreKitHelper sharedInstance].adRemoved ? 0.0f : [KKAdHelper ADSize].height)

#define weakify(obj) __weak typeof(obj) weak_##obj = obj;
#define strongify(obj) __strong typeof(obj) strong_##obj = weak_##obj;

typedef void(^EmptyAction)(void);
#define CALL_BLOCK(block, ...) do{ if (block) block(__VA_ARGS__); }while(0);

#define kColorWith16RGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

CG_INLINE NSString *DBPath(void) {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"chinese_chess_%@.sqlite", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]]];
}
#define DB_PATH DBPath()

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#ifdef DEBUG
#define TICK(name) time_t begin_##name = time(NULL);
#define TOCK(name) DLog(#name ": time elapsed: %ld", time(NULL) - begin_##name)
#else
#define TICK(name)
#define TOCK(name)
#endif

#endif
#endif /* prefix_header_h */
