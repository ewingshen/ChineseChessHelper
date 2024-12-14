//
//  CCChessmanDataStructure.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/4.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#ifndef CCChessmanDataStructure_h
#define CCChessmanDataStructure_h

/*
 棋子用一个uint8_t表示，位置也是一个uint8_t。
 表示局面时，棋子+位置合为一个uint16_t: t << 8 + p;
 位置从左上角（0）向右向下到右下角（89）
 */

typedef NS_ENUM(NSUInteger, CCChessmanType) {
    CCChessmanType_None = 0,
    
    CCChessmanType_Red_Ju = 0x01,
    CCChessmanType_Red_Ma,
    CCChessmanType_Red_Pao,
    CCChessmanType_Red_Shuai,
    CCChessmanType_Red_Shi,
    CCChessmanType_Red_Xiang,
    CCChessmanType_Red_Bing,
    
    CCChessmanType_Black_Ju = 0x11,
    CCChessmanType_Black_Ma,
    CCChessmanType_Black_Pao,
    CCChessmanType_Black_Jiang,
    CCChessmanType_Black_Shi,
    CCChessmanType_Black_Xiang,
    CCChessmanType_Black_Zu,
};

typedef uint8_t CCPosition;
#define CCDeadPosition (0xff)
#define CCRowOfPosition(p) ((p) / 9)
#define CCColOfPosition(p) ((p) % 9)
#define CCMakePosition(r, c) ((c) + (r) * 9)

typedef uint16_t CCLiveChessman;
#define CCLiveChessmanPosition(lcp) ((lcp) & 0xff)
#define CCLiveChessmanType(lcp) (((lcp) >> 8) & 0xff)
#define CCMakeLiveChessman(t, p) ((t) << 8 + (p))

#define isRed(cmt) ((cmt & 0x10) == 0)
#define isBlack(cmt) ((cmt & 0x10) != 0)
#define isSameCamp(cmt1, cmt2) ((((cmt1) ^ (cmt2)) >> 4) == 0)

NS_INLINE  NSString * _Nullable fenType(CCChessmanType type) {
    switch (type) {
        case CCChessmanType_None:
            return nil;
        case CCChessmanType_Red_Ju:
            return @"R";
        case CCChessmanType_Red_Ma:
            return @"N";
        case CCChessmanType_Red_Pao:
            return @"C";
        case CCChessmanType_Red_Shuai:
            return @"K";
        case CCChessmanType_Red_Shi:
            return @"A";
        case CCChessmanType_Red_Xiang:
            return @"B";
        case CCChessmanType_Red_Bing:
            return @"P";
        case CCChessmanType_Black_Ju:
            return @"r";
        case CCChessmanType_Black_Ma:
            return @"n";
        case CCChessmanType_Black_Pao:
            return @"c";
        case CCChessmanType_Black_Jiang:
            return @"k";
        case CCChessmanType_Black_Shi:
            return @"a";
        case CCChessmanType_Black_Xiang:
            return @"b";
        case CCChessmanType_Black_Zu:
            return @"p";
        default:
            return nil;
    }
}

NS_INLINE CCChessmanType manType(NSString * _Nonnull fen) {
    if ([@"RNCKABPrnckabp" containsString:fen]) return CCChessmanType_None;
    NSDictionary<NSString *, NSNumber *> *map = @{
        @"R": @(CCChessmanType_Red_Ju),
        @"N": @(CCChessmanType_Red_Ma),
        @"C": @(CCChessmanType_Red_Pao),
        @"K": @(CCChessmanType_Red_Shuai),
        @"A": @(CCChessmanType_Red_Shi),
        @"B": @(CCChessmanType_Red_Xiang),
        @"P": @(CCChessmanType_Red_Bing),
        @"r": @(CCChessmanType_Black_Ju),
        @"n": @(CCChessmanType_Black_Ma),
        @"c": @(CCChessmanType_Black_Pao),
        @"k": @(CCChessmanType_Black_Jiang),
        @"a": @(CCChessmanType_Black_Shi),
        @"b": @(CCChessmanType_Black_Xiang),
        @"p": @(CCChessmanType_Black_Zu),
    };
    int manTypeValue = [map[fen] intValue];
    return (CCChessmanType)manTypeValue;
}

// black_xiang position
typedef NS_ENUM(NSUInteger, CCBXPosition) {
    CCBXPosition_1 = 2,
    CCBXPosition_2 = 6,
    CCBXPosition_3 = 18,
    CCBXPosition_4 = 22,
    CCBXPosition_5 = 26,
    CCBXPosition_6 = 38,
    CCBXPosition_7 = 42,
};

typedef NS_ENUM(NSUInteger, CCBXBarrier) {
    CCBXBarrier_1 = 10,
    CCBXBarrier_2 = 12,
    CCBXBarrier_3 = 14,
    CCBXBarrier_4 = 16,
    CCBXBarrier_5 = 28,
    CCBXBarrier_6 = 30,
    CCBXBarrier_7 = 32,
    CCBXBarrier_8 = 34,
};

typedef NS_ENUM(NSUInteger, CCBSPosition) {
    CCBSPosition_1 = 3,
    CCBSPosition_2 = 5,
    CCBSPosition_3 = 13,
    CCBSPosition_4 = 21,
    CCBSPosition_5 = 23,
};

typedef NS_ENUM(NSUInteger, CCBJPosition) {
    CCBJPosition_1 = 3,
    CCBJPosition_2 = 4,
    CCBJPosition_3 = 5,
    CCBJPosition_4 = 12,
    CCBJPosition_5 = 13,
    CCBJPosition_6 = 14,
    CCBJPosition_7 = 21,
    CCBJPosition_8 = 22,
    CCBJPosition_9 = 23,
};

typedef NS_ENUM(NSUInteger, CCRXPosition) {
    CCRXPosition_1 = 87,
    CCRXPosition_2 = 83,
    CCRXPosition_3 = 71,
    CCRXPosition_4 = 67,
    CCRXPosition_5 = 63,
    CCRXPosition_6 = 51,
    CCRXPosition_7 = 47,
};

typedef NS_ENUM(NSUInteger, CCRXBarrier) {
    CCRXBarrier_1 = 79,
    CCRXBarrier_2 = 77,
    CCRXBarrier_3 = 75,
    CCRXBarrier_4 = 73,
    CCRXBarrier_5 = 61,
    CCRXBarrier_6 = 59,
    CCRXBarrier_7 = 57,
    CCRXBarrier_8 = 55,
};

typedef NS_ENUM(NSUInteger, CCRSPosition) {
    CCRSPosition_1 = 86,
    CCRSPosition_2 = 84,
    CCRSPosition_3 = 76,
    CCRSPosition_4 = 68,
    CCRSPosition_5 = 66,
};

typedef NS_ENUM(NSUInteger, CCRJPosition) {
    CCRJPosition_1 = 86,
    CCRJPosition_2 = 85,
    CCRJPosition_3 = 84,
    CCRJPosition_4 = 77,
    CCRJPosition_5 = 76,
    CCRJPosition_6 = 75,
    CCRJPosition_7 = 68,
    CCRJPosition_8 = 67,
    CCRJPosition_9 = 66,
};

typedef NS_ENUM(NSUInteger, CCCamp) {
    CCCamp_Black,
    CCCamp_Red,
    CCCamp_Both,
};

#endif /* CCChessmanDataStructure_h */
