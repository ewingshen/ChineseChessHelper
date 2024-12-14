//
//  CCChessUtil.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCChessmanDataStructure.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const StartPhase;

typedef NSString * CCChessManName;

extern CCChessManName Red_Ju;
extern CCChessManName Red_Ma;
extern CCChessManName Red_Pao;
extern CCChessManName Red_Shuai;
extern CCChessManName Red_Shi;
extern CCChessManName Red_Xiang;
extern CCChessManName Red_Bing;

extern CCChessManName Black_Ju;
extern CCChessManName Black_Ma;
extern CCChessManName Black_Pao;
extern CCChessManName Black_Jiang;
extern CCChessManName Black_Shi;
extern CCChessManName Black_Xiang;
extern CCChessManName Black_Zu;

@interface CCChessUtil : NSObject

+ (NSString *)spriteNameOf:(CCChessManName)name type:(int)t;

+ (CCChessManName _Nullable)nameOf:(CCChessmanType)cmt;

+ (BOOL)checkPositionValid:(uint8_t)position chessmen:(CCChessmanType)cmt;

/// 自定义格式.
+ (CCPosition)positionFromStr:(NSString *)ps;
+ (NSString *)positionString:(CCPosition)p;
/// Fen格式.
+ (CCPosition)positionFromFen:(NSString *)ps;
+ (NSString *)FenFromPosition:(CCPosition)p;
/// 将Fen格式的move转换为自定义格式.
+ (NSString *)moveListFrom:(NSString *)fenList;

// data from db.
+ ( NSArray<NSString *> * _Nullable)translateMoveList2FriendlyWord:(NSString *)moveList withInitialPhase:(NSData * _Nullable)ip;

// data from fetch.
+ (NSArray<NSData *> *)genPhasesFrom:(NSString *)ip moveList:(NSString *)moveList;
@end

NS_ASSUME_NONNULL_END
