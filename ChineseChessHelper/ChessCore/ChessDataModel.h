//
//  ChessDataModel.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Tie = 0,
    Red = 1,
    Black = 2,
    Unfinished,
} CCGameVictoryType;


@interface CCPlayer : NSObject

@property (nonatomic, assign) int playerID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int accessTime;

@end


@interface CCMatch : NSObject

@property (nonatomic, assign) int matchID;
@property (nonatomic, copy) NSString *clz;
@property (nonatomic, copy) NSString *name;

@end


@interface CCPhase : NSObject

@property (nonatomic, assign) int phaseID;
@property (nonatomic, assign) int manCount;
@property (nonatomic, copy) NSString *presentation;
@property (nonatomic, assign) int points; // 评分

@end

// 布局
@interface CCArrangement : NSObject

@property (nonatomic, assign) int arrangementID;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *branch;

@end

@interface CCGame : NSObject

@property (nonatomic, assign) int gameID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSData *initialPhase;
@property (nonatomic, copy) NSString *moveList;
@property (nonatomic, assign) NSDate *playTime;
@property (nonatomic, copy) NSString *result;

@property (nonatomic, copy) NSString *redTeamName;
@property (nonatomic, copy) NSString *blackTeamName;

@property (nonatomic, strong) CCMatch *match;
@property (nonatomic, strong) CCPlayer *redPlayer;
@property (nonatomic, strong) CCPlayer *blackPlayer;
@property (nonatomic, strong) CCArrangement *arrangement;
@property (nonatomic, copy) NSString *gameType;

//
@property (nonatomic, assign) int moveIndex;

- (CCGameVictoryType)gameResult;

@end

@interface CCBook : NSObject

@property (nonatomic, assign) int bookID;
@property (nonatomic, assign) int matchID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *moveList;

@end


@interface CCOpponent : NSObject

@property (nonatomic, strong) CCPlayer *player;

@property (nonatomic, assign) int redWinCount;
@property (nonatomic, assign) int redTieCount;
@property (nonatomic, assign) int redLoseCount;

@property (nonatomic, assign) int blackWinCount;
@property (nonatomic, assign) int blackTieCount;
@property (nonatomic, assign) int blackLoseCount;

- (int)totalRedCount;
- (int)totalBlackCount;
- (int)totalCount;

@end

@interface CCPlayerYearData : NSObject

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, strong) NSArray<CCGame *> *games;
@property (nonatomic, assign) float winRate;

@end

@interface CCPlayerData : NSObject

@property (nonatomic, strong) NSArray<CCGame *> *allGames;

@property (nonatomic, assign) int redCount;
@property (nonatomic, assign) int blackCount;
@property (nonatomic, assign) int redWinCount;
@property (nonatomic, assign) int blackWinCount;
@property (nonatomic, assign) int redTieCount;
@property (nonatomic, assign) int blackTieCount;

@property (nonatomic, strong) NSArray<CCOpponent *> *opponents;

@property (nonatomic, strong) NSArray<CCPlayerYearData *> *yearData;

@end

typedef NS_ENUM(NSUInteger, CCEngineType) {
    CCEngineType_Pikafish = 0
};

typedef NS_ENUM(NSUInteger, CCEngineColor) {
    /// 分析模式
    CCEngineColor_None = 0,
    /// 引擎执红
    CCEngineColor_Red,
    /// 引擎执黑
    CCEngineColor_Black,
};

@interface CCEngineSetting : NSObject<NSSecureCoding>

@property (nonatomic, assign) CCEngineType type;
@property (nonatomic, assign) CCEngineColor color;
@property (nonatomic, assign) int goDepth;
@property (nonatomic, assign) double goTime;
@property (nonatomic, assign) unsigned int threads;

@end

@interface CCPlayRecord : NSObject

/// fen
@property (nonatomic, assign) int recordID;
@property (nonatomic, assign) CCEngineColor computerColor;
@property (nonatomic, copy) NSString *moveList;
@property (nonatomic, assign) NSTimeInterval playTime;
@property (nonatomic, assign) CCGameVictoryType result;
@property (nonatomic, copy) NSString *comment;

- (NSString *)PGN;

@end

@interface CCPhaseFen: NSObject

@property (nonatomic, assign) int moveIdx;
@property (nonatomic, copy) NSString *position;

@end

@interface CCPlayUnfinishedModel : NSObject<NSSecureCoding>

@property (nonatomic, strong, nullable) CCEngineSetting *setting;
@property (nonatomic, copy) NSString *moveList;

@end

NS_ASSUME_NONNULL_END
