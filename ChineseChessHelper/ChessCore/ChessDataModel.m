//
//  ChessDataModel.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "ChessDataModel.h"

@implementation CCPlayer
@end

@implementation CCMatch
@end

@implementation CCPhase
@end

@implementation CCGame

- (CCGameVictoryType)gameResult {
    if ([self.result isEqualToString:@"和棋"]) {
        return Tie;
    }
    
    if ([self.result isEqualToString:@"红胜"]) {
        return Red;
    }
    
    return Black;
}

@end

@implementation CCArrangement
@end

@implementation CCBook
@end

@implementation CCOpponent;

- (int)totalCount
{
    return [self totalRedCount] + [self totalBlackCount];
}

- (int)totalRedCount
{
    return self.redWinCount + self.redTieCount + self.redLoseCount;
}

- (int)totalBlackCount
{
    return self.blackWinCount + self.blackTieCount + self.blackLoseCount;
}

@end

@implementation CCPlayerData
@end

@implementation CCPlayerYearData

@end


@implementation CCEngineSetting

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.type = [coder decodeIntForKey:@"type"];
        self.color = [coder decodeIntForKey:@"color"];
        self.goDepth = [coder decodeIntForKey:@"goDepth"];
        self.goTime = [coder decodeFloatForKey:@"goTime"];
        self.threads = [coder decodeIntForKey:@"threads"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeInt:(int)self.type forKey:@"type"];
    [coder encodeInt:(int)self.color forKey:@"color"];
    [coder encodeInt:self.goDepth forKey:@"goDepth"];
    [coder encodeFloat:self.goTime forKey:@"goTime"];
    [coder encodeInt:self.threads forKey:@"threads"];
}

@end

@implementation CCPlayRecord

- (NSString *)PGN
{
    /// TODO: generate PGN file.
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CCPlayRecord: {id: %d, color: %lu, moveList: %@, time: %f, result: %lu, comment: %@}", self.recordID, (unsigned long)self.computerColor, self.moveList, self.playTime, (unsigned long)self.result, self.comment];
}

@end


@implementation CCPhaseFen

@end


@implementation CCPlayUnfinishedModel

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.setting = [coder decodeObjectOfClass:[CCEngineSetting class] forKey:@"setting"];
        self.moveList = [coder decodeObjectForKey:@"moveList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.setting forKey:@"setting"];
    [coder encodeObject:self.moveList forKey:@"moveList"];
}

@end
