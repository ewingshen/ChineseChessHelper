//
//  CCChesscore.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChessDataModel.h"
#import "CCChessmanDataStructure.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCChessGameSortType) {
    CCChessGameSortType_Date,
    CCChessGameSortType_Title,
};

typedef void(^LoadRecordsCompletion)(NSArray<CCPlayRecord *> *records);

@interface CCChesscore : NSObject

+ (instancetype)core;

- (NSArray<CCMatch *> *)allMatch;
- (NSArray<CCMatch *> *)matchesUnderClass:(NSString *)className;
- (NSArray<CCMatch *> *)oldBooks;
- (NSArray<CCGame *> *)queryAllGameByMatch:(NSInteger)matchID;

- (NSArray<CCPlayer *> *)allPlayers;
- (NSArray<CCPlayer *> *)playerAccessHistory;
- (CCPlayer *)playerWithName:(NSString *)name;
- (CCPlayer *)playerWithID:(int)playerID;
- (void)increaseAccessTime:(int)playerID;

- (NSArray<CCGame *> *)queryGameWithPhase:(NSData * _Nullable)phasePresentation
                                   redPlayer:(NSInteger)redPlayerID
                              blackPlayer:(NSInteger)blackPlayerID
                               ignoreSide:(BOOL)ignore
                                    match:(NSInteger)matchID
                                startTime:(NSTimeInterval)st
                                  endTime:(NSTimeInterval)et
                                pageIndex:(int)pi
                                 pageSize:(int)ps
                                 sortType:(CCChessGameSortType)sortType
                                  sortAsc:(BOOL)asc;


- (void)stopQuery;

- (CCPlayerData *)queryPlayerInfoOf:(CCPlayer *)p;

- (NSString *)queryNextStep:(NSData *)phase player:(NSInteger)pid isRed:(BOOL)isRed requireWin:(Boolean)rw moveIndex:(out nonnull int *)mi;

- (void)saveRecord:(CCPlayRecord *)r;
- (void)removeRecord:(int)rid;
- (void)loadRecordAt:(int)page pageSize:(int)ps completion:(LoadRecordsCompletion)cmp;

#pragma mark -  save last play state.
- (CCPlayUnfinishedModel *)lastPlayModel:(BOOL)isSelfPlay;
- (void)saveLastPlay:(CCPlayUnfinishedModel *)model isSelfPlay:(BOOL)selfPlay;
- (void)clearLastPlay:(BOOL)isSelfPlay;
#pragma mark - Settings
@property (nonatomic, assign) int chessboardType;
@property (nonatomic, assign) float autoPlayDelay;
@property (nonatomic, assign) int analyzaDepth;
@end

NS_ASSUME_NONNULL_END
