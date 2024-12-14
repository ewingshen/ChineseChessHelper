//
//  CCChessUtil.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCChessUtil.h"

CCChessManName Red_Ju = @"車";
CCChessManName Red_Ma = @"馬";
CCChessManName Red_Pao = @"炮";
CCChessManName Red_Shuai = @"帅";
CCChessManName Red_Shi = @"仕";
CCChessManName Red_Xiang = @"相";
CCChessManName Red_Bing = @"兵";
CCChessManName Black_Ju = @"车";
CCChessManName Black_Ma = @"马";
CCChessManName Black_Pao = @"砲";
CCChessManName Black_Jiang = @"将";
CCChessManName Black_Shi = @"士";
CCChessManName Black_Xiang = @"象";
CCChessManName Black_Zu = @"卒";

NSString * const StartPhase = @"8979695949392919097717866646260600102030405060708012720323436383";

@implementation CCChessUtil

+ (NSString *)spriteNameOf:(CCChessManName)name type:(int)t
{
    return [NSString stringWithFormat:@"%@%d", @{
            Red_Ju: @"rc",
            Red_Ma: @"rm",
            Red_Pao: @"rp",
            Red_Bing: @"rb",
            Red_Shi: @"rs",
            Red_Xiang: @"rx",
            Red_Shuai: @"shuai",
            
            Black_Ju: @"bc",
            Black_Ma: @"bm",
            Black_Pao: @"bp",
            Black_Zu: @"bz",
            Black_Shi: @"bs",
            Black_Xiang: @"bx",
            Black_Jiang: @"jiang",
    }[name], t];
}

+ (CCChessManName)nameOf:(CCChessmanType)cmt
{
    if (cmt & 0x10) {
        NSArray *blackNames = @[Black_Ju, Black_Ma, Black_Pao, Black_Jiang, Black_Shi, Black_Xiang, Black_Zu];
        int index = (int)cmt - 0x11;
        if (index < 0 || index >= blackNames.count) return nil;
        return blackNames[index];
    } else {
        NSArray *redNames = @[Red_Ju, Red_Ma, Red_Pao, Red_Shuai, Red_Shi, Red_Xiang, Red_Bing];
        int index = (int)cmt - 0x01;
        if (index < 0 || index >= redNames.count) return nil;
        return redNames[index];
    }
}

+ (BOOL)checkPositionValid:(uint8_t)position chessmen:(CCChessmanType)cmt
{
    NSSet *validPositions = nil;
    switch (cmt) {
        case CCChessmanType_Red_Ju:
        case CCChessmanType_Red_Ma:
        case CCChessmanType_Red_Pao:
            break;
        case CCChessmanType_Red_Shuai:
            validPositions = [NSSet setWithObjects:@86, @85, @84, @77, @76, @75, @68, @67, @66, nil];
            break;
        case CCChessmanType_Red_Shi:
            validPositions = [NSSet setWithObjects:@86, @84, @76, @68, @66, nil];
            break;
        case CCChessmanType_Red_Xiang:
            validPositions = [NSSet setWithObjects:@87, @83, @71, @67, @63, @51, @47, nil];
            break;
        case CCChessmanType_Red_Bing:
        {
            uint8_t row = position / 9;
            uint8_t col = position % 9;
            if (row <= 6) {
                if (row <= 4) {
                    return YES;
                } else {
                    return col % 2 == 0;
                }
            } else {
                return NO;
            }
        }
            break;
            
        case CCChessmanType_Black_Ju:
        case CCChessmanType_Black_Ma:
        case CCChessmanType_Black_Pao:
            break;
        case CCChessmanType_Black_Jiang:
            validPositions = [NSSet setWithObjects:@3, @4, @5, @12, @13, @14, @21, @22, @23, nil];
            break;
        case CCChessmanType_Black_Shi:
            validPositions = [NSSet setWithObjects:@3, @5, @13, @21, @23, nil];
            break;
        case CCChessmanType_Black_Xiang:
            validPositions = [NSSet setWithObjects:@2, @6, @18, @22, @26, @38, @42, nil];
            break;
        case CCChessmanType_Black_Zu:
        {
            uint8_t row = position / 9;
            uint8_t col = position % 9;
            if (row > 2) {
                if (row <= 4) {
                    return col % 2 == 0;
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
        }
            break;
        default:
            break;
    }
    
    if (validPositions) {
        return [validPositions containsObject:@(position)];
    }
    
    return YES;
}

+ (CCPosition)positionFromStr:(NSString *)ps
{
    if (ps.length > 1) {
        CCPosition col = [[ps substringWithRange:NSMakeRange(0, 1)] intValue];
        CCPosition row = [[ps substringWithRange:NSMakeRange(1, 1)] intValue];
        
        return CCMakePosition(row, col);
    }
    
    return CCDeadPosition;
}

+ (NSString *)positionString:(CCPosition)p
{
    return [NSString stringWithFormat:@"%d%d", CCColOfPosition(p), CCRowOfPosition(p)];
}

+ (CCPosition)positionFromFen:(NSString *)ps
{
    if (ps.length > 1) {
        CCPosition col = [[ps substringWithRange:NSMakeRange(0, 1)] characterAtIndex:0] - 'a';
        CCPosition row = 9 - [[ps substringWithRange:NSMakeRange(1, 1)] intValue];
        return CCMakePosition(row, col);
    }
    
    return CCDeadPosition;
}

+ (NSString *)FenFromPosition:(CCPosition)p
{
    CCPosition col = CCColOfPosition(p);
    CCPosition row = CCRowOfPosition(p);
    
    return [NSString stringWithFormat:@"%c%d", col + 'a', 9 - row];
}

+ (NSString *)moveListFrom:(NSString *)fenList
{
    fenList = [fenList stringByReplacingOccurrencesOfString:@" " withString:@""];
    int len = (int)fenList.length / 2;
    
    NSMutableString *rslt = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        NSString *sub = [fenList substringWithRange:NSMakeRange(i * 2, 2)];
        CCPosition p = [self positionFromFen:sub];
        [rslt appendString:[self positionString:p]];
    }
    
    return rslt;
}

/*
 * @param toChinese 是否转换为汉字的数字
 */
+ (NSString *)numberDesc:(int)n toChinese:(BOOL)tc
{
    if (tc) {
        NSArray *chineseNumber = @[@"零", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十"];
        return chineseNumber[n];
    } else {
        return [NSString stringWithFormat:@"%d", n];
    }
}

+ (NSString *)colDesc:(CCPosition)p isRed:(BOOL)isRed
{
    CCPosition col = CCColOfPosition(p);
    col += 1;
    
    if (isRed) {
        col = 10 - col;
    }
      
    return [self numberDesc:col toChinese:isRed];
}

+ (NSString *)positionDesc:(CCPosition)p isRed:(BOOL)isRed
{
    NSString *colDesc = [self colDesc:p isRed:isRed];
    CCPosition row = CCRowOfPosition(p);
    row += 1;
    if (isRed) {
        row = 11 - row;
    }
    return [NSString stringWithFormat:@"%@%@", colDesc, [self numberDesc:row toChinese:isRed]];
}

+ (NSString *)directionDescFrom:(CCPosition)fp to:(CCPosition)tp isRed:(BOOL)isRed
{
    CCPosition fr = CCRowOfPosition(fp);
    CCPosition tr = CCRowOfPosition(tp);
    
    if (isRed) {
        fr = 9 - fr;
        tr = 9 - tr;
    }
    
    if (tr > fr) {
        return @"进";
    } else if (tr == fr) {
        return @"平";
    } else {
        return @"退";
    }
}

+ (NSArray<NSString *> *)translateMoveList2FriendlyWord:(NSString *)moveList withInitialPhase:(NSData *)ip
{
    NSUInteger moveCount = moveList.length / 4;
    NSMutableArray *moves = [NSMutableArray arrayWithCapacity:moveCount];
    
    CCChessmanType chessboard[90] = {
        // row 0:
        CCChessmanType_Black_Ju, CCChessmanType_Black_Ma, CCChessmanType_Black_Xiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Jiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Xiang, CCChessmanType_Black_Ma, CCChessmanType_Black_Ju,
        // row 1:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 2:
        0, CCChessmanType_Black_Pao, 0, 0, 0, 0, 0, CCChessmanType_Black_Pao, 0,
        // row 3:
        CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu,
        // row 4:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 5:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 6:
        CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing,
        // row 7:
        0, CCChessmanType_Red_Pao, 0, 0, 0, 0, 0, CCChessmanType_Red_Pao, 0,
        // row 8:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 9:
        CCChessmanType_Red_Ju, CCChessmanType_Red_Ma, CCChessmanType_Red_Xiang, CCChessmanType_Red_Shi, CCChessmanType_Red_Shuai, CCChessmanType_Red_Shi, CCChessmanType_Red_Xiang, CCChessmanType_Red_Ma, CCChessmanType_Red_Ju,
    };
    
    if (ip.length > 0) {
        memset(chessboard, 0, sizeof(CCChessmanType) * 90);
        
        const BytePtr bytes = (BytePtr)ip.bytes;
        for (size_t i = 0; i < ip.length; i += 3) {
            CCChessmanType t1 = CCChessmanType_None;
            CCChessmanType t2 = CCChessmanType_None;
            CCPosition p1 = CCDeadPosition;
            CCPosition p2 = CCDeadPosition;
            
            Byte b1 = bytes[i];
            Byte b2 = bytes[i + 1];
            
            t1 = b1 >> 3;
            p1 = ((b1 & 0x07) << 4) + (b2 >> 4);
            
            if (i + 2 < ip.length) {
                Byte b3 = bytes[i+2];
                t2 = ((b2 & 0xF) << 1) + (b3 >> 7);
                p2 = b3 & 0x7F;
            }
            
            if (p1 < 90 && p1 != CCDeadPosition) {
                chessboard[p1] = t1;
            }
            
            if (p2 < 90 && p2 != CCDeadPosition) {
                chessboard[p2] = t2;
            }
        }
    }
    
    for (NSUInteger i = 0; i < moveCount; i++) {
        NSString *move = [moveList substringWithRange:NSMakeRange(i * 4, 4)];
        CCPosition fp = [self positionFromStr:[move substringToIndex:2]];
        CCPosition tp = [self positionFromStr:[move substringFromIndex:2]];
        
        CCChessmanType man = chessboard[fp];
        BOOL isRedMove = i % 2 == 0;

        if (man <= 0 || (man > 0x07 && man < 0x11) || man > 0x17) {
            return nil;
        }
        
        NSString *manName = [self nameOf:man];
        if (manName == nil) {
            return nil;
        }
        
        NSMutableString *moveStr = [NSMutableString stringWithCapacity:4];
        
        // 针对车、马、炮、兵（卒）需要判断是否存在前后的情况
        if (man == CCChessmanType_Red_Ju || man == CCChessmanType_Black_Ju
            || man == CCChessmanType_Red_Ma || man == CCChessmanType_Black_Ma
            || man == CCChessmanType_Red_Pao || man == CCChessmanType_Black_Pao
            || man == CCChessmanType_Red_Bing || man == CCChessmanType_Black_Zu) {
            
            int frontSameCount = 0;
            int backSameCount = 0;
            
            for (int bp = fp - 9; bp >= 0; bp -= 9) {
                if (chessboard[bp] == man) {
                    backSameCount += 1;
                }
            }
            
            for (int bp = fp + 9; bp <= 89; bp += 9) {
                if (chessboard[bp] == man) {
                    frontSameCount += 1;
                }
            }
            
            if (isRedMove) {
                // 红方的话，前后要交换一下
                int t = frontSameCount;
                frontSameCount = backSameCount;
                backSameCount = t;
            }
            
            if (frontSameCount + backSameCount > 0) {
                if (frontSameCount + backSameCount > 1) {
                    // 只有兵、卒会出现这种情况
                    [moveStr appendFormat:@"%@%@", manName, [self positionDesc:fp isRed:isRedMove]];
                } else {
                    if (frontSameCount > 0) {
                        [moveStr appendString:@"后"];
                    } else {
                        [moveStr appendString:@"前"];
                    }
                    [moveStr appendString:manName];
                }
            } else {
                [moveStr appendFormat:@"%@%@", manName, [self colDesc:fp isRed:isRedMove]];
            }
        } else {
            [moveStr appendFormat:@"%@%@", manName, [self colDesc:fp isRed:isRedMove]];
        }
        
        [moveStr appendString:[self directionDescFrom:fp to:tp isRed:isRedMove]];
        if (CCColOfPosition(fp) == CCColOfPosition(tp)) {
            [moveStr appendString:[self numberDesc:abs(CCRowOfPosition(fp) - CCRowOfPosition(tp)) toChinese:isRedMove]];
        } else {
            [moveStr appendString:[self colDesc:tp isRed:isRedMove]];
        }
        
        [moves addObject:moveStr];
        
        // 修改位置信息
        chessboard[fp] = 0;
        chessboard[tp] = man;
    }
    
    return moves;
}

+ (NSArray<NSData *> *)genPhasesFrom:(NSString *)ip moveList:(NSString *)moveList
{
    CCChessmanType chessboard[90] = {
        // row 0:
        CCChessmanType_Black_Ju, CCChessmanType_Black_Ma, CCChessmanType_Black_Xiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Jiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Xiang, CCChessmanType_Black_Ma, CCChessmanType_Black_Ju,
        // row 1:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 2:
        0, CCChessmanType_Black_Pao, 0, 0, 0, 0, 0, CCChessmanType_Black_Pao, 0,
        // row 3:
        CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu, 0, CCChessmanType_Black_Zu,
        // row 4:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 5:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 6:
        CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing, 0, CCChessmanType_Red_Bing,
        // row 7:
        0, CCChessmanType_Red_Pao, 0, 0, 0, 0, 0, CCChessmanType_Red_Pao, 0,
        // row 8:
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        // row 9:
        CCChessmanType_Red_Ju, CCChessmanType_Red_Ma, CCChessmanType_Red_Xiang, CCChessmanType_Red_Shi, CCChessmanType_Red_Shuai, CCChessmanType_Red_Shi, CCChessmanType_Red_Xiang, CCChessmanType_Red_Ma, CCChessmanType_Red_Ju,
    };
    
    if (ip.length > 0) {
        memset(chessboard, 0, sizeof(CCChessmanType) * 90);
        
        CCChessmanType cms[32] = {
            CCChessmanType_Red_Ju, CCChessmanType_Red_Ma, CCChessmanType_Red_Xiang, CCChessmanType_Red_Shi, CCChessmanType_Red_Shuai, CCChessmanType_Red_Shi, CCChessmanType_Red_Xiang, CCChessmanType_Red_Ma, CCChessmanType_Red_Ju, CCChessmanType_Red_Pao, CCChessmanType_Red_Pao, CCChessmanType_Red_Bing, CCChessmanType_Red_Bing, CCChessmanType_Red_Bing, CCChessmanType_Red_Bing, CCChessmanType_Red_Bing,
            CCChessmanType_Black_Ju, CCChessmanType_Black_Ma, CCChessmanType_Black_Xiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Jiang, CCChessmanType_Black_Shi, CCChessmanType_Black_Xiang, CCChessmanType_Black_Ma, CCChessmanType_Black_Ju, CCChessmanType_Black_Pao, CCChessmanType_Black_Pao, CCChessmanType_Black_Zu, CCChessmanType_Black_Zu, CCChessmanType_Black_Zu, CCChessmanType_Black_Zu, CCChessmanType_Black_Zu,
        };
        
        for (int i = 0; i < 32; i++) {
            NSString *posStr = [ip substringWithRange:NSMakeRange(i * 2, i * 2 + 2)];
            CCPosition p = [self positionFromStr:posStr];
            chessboard[p] = cms[i];
        }
    }
    
    
    NSData * (^dataFromChessboard)(CCChessmanType[]) = ^(CCChessmanType board[]){
        NSMutableData *data = [NSMutableData data];
        
        CCChessmanType firstType = 0;
        CCPosition firstPos = CCDeadPosition;
        for (int i = 0; i < 90; i++) {
            if (board[i] != 0) {
                if (firstType == 0) {
                    firstType = board[i];
                    firstPos = i;
                } else {
                    CCChessmanType secondType = board[i];
                    CCPosition secondPos = i;
                    
                    Byte b1 = (firstType << 3) + ((firstPos & 0x70) >> 4);
                    Byte b2 = ((firstPos & 0x0F) << 4) + ((secondType & 0x1E) >> 1);
                    Byte b3 = ((secondType & 0x1) << 7) + (secondPos & 0x7F);
                    
                    [data appendBytes:&b1 length:1];
                    [data appendBytes:&b2 length:1];
                    [data appendBytes:&b3 length:1];
                    
                    firstType = 0;
                    firstPos = CCDeadPosition;
                }
            }
        }
        
        if (firstType != 0) {
            CCChessmanType secondType = 2^6 - 1;
            
            Byte b1 = (firstType << 3) + ((firstPos & 0x70) >> 4);
            Byte b2 = ((firstPos & 0x0F) << 4) + ((secondType & 0x1E) >> 1);
            
            [data appendBytes:&b1 length:1];
            [data appendBytes:&b2 length:1];
        }
        
        return data;
    };
    
    NSUInteger moveCount = moveList.length / 4;
    NSMutableArray *phases = [NSMutableArray arrayWithCapacity:moveCount + 1];
    [phases addObject:dataFromChessboard(chessboard)];
    
    for (NSUInteger i = 0; i < moveCount; i++) {
        NSString *move = [moveList substringWithRange:NSMakeRange(i * 4, 4)];
        CCPosition fp = [self positionFromStr:[move substringToIndex:2]];
        CCPosition tp = [self positionFromStr:[move substringFromIndex:2]];
        chessboard[tp] = chessboard[fp];
        chessboard[fp] = 0;
        
        [phases addObject:dataFromChessboard(chessboard)];
    }
    
    return phases;
}
@end
