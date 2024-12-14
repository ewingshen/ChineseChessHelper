//
//  CCChesscore.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCChesscore.h"
#import "CCChessUtil.h"
#import <FMDB.h>
#import "NSMutableDictionary+CCUtil.h"

@interface CCChesscore ()

@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSArray<CCPlayer *> *allPlayers;

// chess board type store.
@property (nonatomic, strong) NSNumber *cbt;
@property (nonatomic, strong) NSNumber *apd;
@property (nonatomic, strong) NSNumber *depth;

@property (nonatomic, strong) NSCache *cache;

// for self play
@property (nonatomic, strong) FMDatabaseQueue *recordQueue;

@end

@implementation CCChesscore

- (instancetype)initWithDB:(NSString *)dbFilePath
{
    self = [super init];
    if (self) {
        self.queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
        [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
            db.shouldCacheStatements = YES;
            
            [db executeStatements:@"PRAGMA journal_mode=WAL;"];
        }];
        
        self.recordQueue = [FMDatabaseQueue databaseQueueWithPath:[self recordDBPath]];
        [self.recordQueue inDatabase:^(FMDatabase * _Nonnull db) {
            db.shouldCacheStatements = YES;
            
            [db executeStatements:@"PRAGMA journal_mode=WAL;"];
        }];
        
        [self.recordQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            
            NSString* createTableSql = @"\
            CREATE TABLE IF NOT EXISTS `record`(\
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,\
            `color` INTEGER,\
            `moves` TEXT NOT NULL,\
            `time` BIGINT,\
            `result` INTEGER,\
            `comment` TEXT,\
            UNIQUE(`color`, `moves`, `time`, `result`)\
            );\
            ";
            
            [db executeStatements:createTableSql];
        }];
        
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)core
{
    static CCChesscore *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[CCChesscore alloc] initWithDB:DB_PATH];
    });
    return singleton;
}

- (void)dealloc
{
    [self.queue close];
}

#pragma mark - Public Methods

- (NSArray<CCMatch *> *)allMatch
{
    __block NSArray<CCMatch *> *result = nil;
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT id, class, name FROM match WHERE class not like '象棋谱大全-古谱_局' ORDER BY name DESC;"];
        NSMutableArray<CCMatch *> *rslt = [NSMutableArray array];
        while ([rs next]) {
            CCMatch *m = [self matchFrom:rs];
            [rslt addObject:m];
        }
        [rs close];
        
        result = [rslt copy];
    }];
    
    return result;
}

- (NSArray<CCMatch *> *)oldBooks
{
    __block NSArray<CCMatch *> *result = nil;
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT id, class, name FROM match WHERE class LIKE '象棋谱大全-古谱%局' ORDER BY name;"];
        NSMutableArray<CCMatch *> *rslt = [NSMutableArray array];
        while ([rs next]) {
            CCMatch *m = [self matchFrom:rs];
            if ([m.name isEqualToString:@"桔中秘"]) {
                if ([m.clz isEqualToString:@"象棋谱大全-古谱残局"]) {
                    m.name = @"桔中秘·残";
                } else {
                    m.name = @"桔中秘·全";
                }
            }
            [rslt addObject:m];
        }
        [rs close];
        
        result = [rslt copy];
    }];
    
    return result;
}

- (NSArray<CCMatch *> *)matchesUnderClass:(NSString *)className
{
    __block NSArray<CCMatch *> *result = nil;
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT id, class, name FROM match WHERE class=?;" withArgumentsInArray:@[className]];
        NSMutableArray<CCMatch *> *rslt = [NSMutableArray array];
        while ([rs next]) {
            CCMatch *m = [self matchFrom:rs];
            [rslt addObject:m];
        }
        [rs close];
        
        result = [rslt copy];
    }];
    
    return result;
}

- (NSArray<CCGame *> *)queryAllGameByMatch:(NSInteger)matchID
{
    return [self queryGameWithPhase:nil redPlayer:0 blackPlayer:0 ignoreSide:NO match:matchID startTime:0 endTime:0 pageIndex:0 pageSize:0 sortType:CCChessGameSortType_Date sortAsc:YES];
}

- (NSArray<CCPlayer *> *)allPlayers
{
    if (!_allPlayers) {
        __block NSArray<CCPlayer *> *result = nil;
        [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            FMResultSet *rs = [db executeQuery:@"SELECT id, name, access_time FROM player ORDER BY name;"];
            NSMutableArray *t = [NSMutableArray array];
            while ([rs next]) {
                CCPlayer *p = [self playerFrom:rs];
                [t addObject:p];
            }
            [rs close];
            
            result = [t copy];
        }];
        
        _allPlayers = result;
    }
    
    return _allPlayers;
}

- (NSArray<CCPlayer *> *)playerAccessHistory
{
    NSArray *sorted = [[self allPlayers] sortedArrayUsingComparator:^NSComparisonResult(CCPlayer*  _Nonnull obj1, CCPlayer*  _Nonnull obj2) {
        return obj1.accessTime < obj2.accessTime;
    }];
    
    NSMutableArray *arr = [NSMutableArray array];
    for(int i = 0; i < 5 && i < sorted.count; i++) {
        CCPlayer *p = sorted[i];
        if (p.accessTime > 0) {
            [arr addObject:p];
        } else {
            break;
        }
    }
    return arr;
}

- (CCPlayer *)playerWithID:(int)playerID
{
    for (CCPlayer *p in self.allPlayers) {
        if (p.playerID == playerID) {
            return p;
        }
    }
    
    return nil;
}

- (void)increaseAccessTime:(int)playerID
{
    for (CCPlayer *p in self.allPlayers) {
        if (p.playerID == playerID) {
            p.accessTime += 1;
            break;
        }
    }
    
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [db executeUpdate:@"UPDATE `player` SET `access_time`=`access_time`+1 WHERE `id`=?" withArgumentsInArray:@[@(playerID)]];
        NSError *e = [db lastError];
        if (e) {
            DLog(@"failed to increas player(%d) access time with error: %@", playerID, e);
        }
    }];
}

- (CCPlayer *)playerWithName:(NSString *)name
{
    if (name.length == 0) {
        return nil;
    }
    
    for (CCPlayer *p in self.allPlayers) {
        if ([p.name isEqualToString:name]) {
            return p;
        }
    }
    
    return nil;
}

- (NSArray<CCGame *> *)queryGameWithPhase:(NSData *)phasePresentation
                                redPlayer:(NSInteger)redPlayerID
                              blackPlayer:(NSInteger)blackPlayerID
                               ignoreSide:(BOOL)ignore
                                    match:(NSInteger)matchID
                                startTime:(NSTimeInterval)st
                                  endTime:(NSTimeInterval)et
                                pageIndex:(int)pi
                                 pageSize:(int)ps
                                 sortType:(CCChessGameSortType)sortType
                                  sortAsc:(BOOL)asc
{
    __block NSArray<CCGame *> *ret = nil;
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSMutableString *query = nil;
        if (phasePresentation.length > 0) {
            query = [NSMutableString stringWithString:@"SELECT g.id, g.move_list, g.result, g.red_id, red.name, g.red_team, g.black_id, black.name, g.black_team, g.match_id, match.class, match.name, g.arrange_id, arrange.number, arrange.name, arrange.branch, g.game_type, g.date, g.title, gh.move_index \
                     FROM game AS g INNER JOIN player AS red ON red.id = g.red_id \
                     INNER JOIN player AS black ON black.id = g.black_id \
                     INNER JOIN match ON match.id = g.match_id \
                     INNER JOIN arrange ON arrange.id = g.arrange_id \
                     INNER JOIN game_phase AS gh ON gh.game_id = g.id \
                     INNER JOIN phase AS ph ON gh.phase_id = ph.id \
                     WHERE TRUE"];
        } else {
            query = [NSMutableString stringWithString:@"SELECT g.id, g.move_list, g.result, g.red_id, red.name, g.red_team, g.black_id, black.name, g.black_team, g.match_id, match.class, match.name, g.arrange_id, arrange.number, arrange.name, arrange.branch, g.game_type, g.date, g.title \
            FROM game AS g INNER JOIN player AS red ON red.id = g.red_id \
            INNER JOIN player AS black ON black.id = g.black_id \
            INNER JOIN match ON match.id = g.match_id \
            INNER JOIN arrange ON arrange.id = g.arrange_id \
            WHERE TRUE"];
        }
        
        if (phasePresentation.length > 0) {
            [query appendString:@" AND ph.presentation = ?"];
        }
        
        if (redPlayerID > 0 && redPlayerID == blackPlayerID) {
            [query appendString:@" AND (g.red_id = ? OR g.black_id = ?)"];
        } else {
            if (redPlayerID > 0) {
                if (ignore) {
                    [query appendString:@" AND (g.red_id = ? OR g.black_id = ?)"];
                } else {
                    [query appendString:@" AND g.red_id = ?"];
                }
            }
            
            if (blackPlayerID > 0) {
                if (ignore) {
                    [query appendString:@" AND (g.red_id = ? OR g.black_id = ?)"];
                } else {
                    [query appendString:@" AND g.black_id = ?"];
                }
            }
        }
        
        if (matchID > 0) {
            [query appendString:@" AND g.match_id = ?"];
        }
        
        if (st != NSNotFound) {
            [query appendString:@" AND g.date > ?"];
        }
        
        if (et != NSNotFound) {
            [query appendString:@" AND g.date < ?"];
        }
        
        if (sortType == CCChessGameSortType_Date) {
            [query appendString:@" ORDER BY g.date"];
        } else if (sortType == CCChessGameSortType_Title) {
            [query appendString:@" ORDER BY g.title"];
        }
        
        if (!asc) {
            [query appendString:@" DESC"];
        }
        
        if (ps > 0) {
            [query appendFormat:@" LIMIT %d,%d", ps * pi, ps];
        }
        
        [query appendString:@";"];
        
        DLog(@"query is: %@", query);
        
        NSMutableArray *args = [NSMutableArray array];
        if (phasePresentation.length > 0) {
            [args addObject:phasePresentation];
        }
        
        if (redPlayerID > 0) {
            [args addObject:@(redPlayerID)];
            if (ignore) {
                [args addObject:@(redPlayerID)];
            }
        }
        
        if (blackPlayerID > 0) {
            [args addObject:@(blackPlayerID)];
            if (ignore) {
                [args addObject:@(blackPlayerID)];
            }
        }
        
        if (matchID > 0) {
            [args addObject:@(matchID)];
        }
        
        if (st != NSNotFound) {
            [args addObject:@(st)];
        }
        
        if (et != NSNotFound) {
            [args addObject:@(et)];
        }
        
        TICK(query_game)
        
        FMResultSet *rs = [db executeQuery:query withArgumentsInArray:args];
        NSMutableArray *result = [NSMutableArray array];
        while ([rs next]) {
            CCGame *game = [self gameFrom:rs];
            [result addObject:game];
        }
        [rs close];
        
        TOCK(query_game)
        
        TICK(query_init_phase)
        
        if (result.count > 0) {
            NSMutableString *gameIdStr = [NSMutableString stringWithString:@"("];
            for (CCGame *game in result) {
                if ((![game.gameType isEqualToString:@"全局"] && ![game.match.clz isEqualToString:@"象棋谱大全-古谱全局"]) || [game.match.clz isEqualToString:@"象棋谱大全-古谱残局"]) {
                    [gameIdStr appendFormat:@"%d,", game.gameID];
                }
            }
            
            [gameIdStr deleteCharactersInRange:NSMakeRange(gameIdStr.length - 1, 1)];
            [gameIdStr appendString:@")"];

            if (gameIdStr.length > 2) {
                FMResultSet *prs = [db executeQuery:[NSString stringWithFormat:@"SELECT ph.presentation, gh.game_id From phase AS ph INNER JOIN game_phase AS gh ON gh.phase_id = ph.id WHERE gh.move_index = 0 AND gh.game_id IN %@;", gameIdStr]];
                while ([prs next]) {
                    NSData *phase = [prs dataForColumnIndex:0];
                    int gameID = [prs intForColumnIndex:1];
                    for (CCGame *game in result) {
                        if (game.gameID == gameID) {
                            game.initialPhase = phase;
                        }
                    }
                }
                
                [prs close];
            }
        }
        
        TOCK(query_init_phase)
        
        ret = [result copy];
    }];
    
    return ret;
}

- (void)stopQuery
{
    [self.queue interrupt];
}

- (CCPlayerData *)queryPlayerInfoOf:(CCPlayer *)p
{
    CCPlayerData *cacheData = [self.cache objectForKey:@(p.playerID)];
    if (cacheData != nil) {
        return cacheData;
    }
    
    __block CCPlayerData *rslt = nil;
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        TICK(query_player_all_game)
        FMResultSet *rs = [db executeQuery:@"SELECT g.id, g.move_list, g.result, g.red_id, red.name, g.red_team, g.black_id, black.name, g.black_team, g.match_id, match.class, match.name, g.arrange_id, arrange.number, arrange.name, arrange.branch, g.game_type, g.date, g.title \
                           FROM game AS g LEFT OUTER JOIN player AS red ON red.id = g.red_id \
                           LEFT OUTER JOIN player AS black ON black.id = g.black_id \
                           LEFT OUTER JOIN match ON match.id = g.match_id \
                           LEFT OUTER JOIN arrange ON arrange.id = g.arrange_id WHERE red.id = ? OR black.id = ? ORDER BY g.date DESC;"
                      withArgumentsInArray:@[@(p.playerID), @(p.playerID)]];
        NSMutableArray *games = [NSMutableArray array];
        while ([rs next]) {
            CCGame *game = [self gameFrom:rs];
            if (game) {
                [games addObject:game];
            }
        }
        [rs close];
        
        TOCK(query_player_all_game)
        
        int totalRed = 0;
        int totalBlack = 0;
        int totalRedWin = 0;
        int totalBlackWin = 0;
        int totalRedTie = 0;
        int totalBlackTie = 0;
        NSMutableDictionary<NSNumber *, CCOpponent *> *opponents = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSNumber *, CCPlayerYearData*> *yearData = [NSMutableDictionary dictionary];
        for (CCGame *game in games) {
            BOOL isRed = game.redPlayer.playerID == p.playerID;
            CCOpponent *opn = nil;
            if (isRed) {
                totalRed += 1;
                opn = opponents[@(game.blackPlayer.playerID)];
            } else {
                totalBlack += 1;
                opn = opponents[@(game.redPlayer.playerID)];
            }
            
            if (!opn) {
                opn = [[CCOpponent alloc] init];
                if (isRed) {
                    opn.player = game.blackPlayer;
                } else {
                    opn.player = game.redPlayer;
                }
                opponents[@(opn.player.playerID)] = opn;
            }
            
            switch (game.gameResult) {
                case Tie:
                    if (isRed) {
                        totalRedTie += 1;
                        opn.redTieCount += 1;
                    } else {
                        totalBlackTie += 1;
                        opn.blackTieCount += 1;
                    }
                    break;
                case Red:
                    if (isRed) {
                        totalRedWin += 1;
                        opn.redWinCount += 1;
                    } else {
                        opn.blackLoseCount += 1;
                    }
                    break;
                case Black:
                    if (isRed) {
                        opn.redLoseCount += 1;
                    } else {
                        totalBlackWin += 1;
                        opn.blackWinCount += 1;
                    }
                    break;
                case Unfinished:
                    break;
            }
            
            NSInteger year = [calendar component:NSCalendarUnitYear fromDate:game.playTime];
            CCPlayerYearData *data = yearData[@(year)];
            if (data == nil) {
                data = [CCPlayerYearData new];
                data.year = year;
                data.games = [NSArray arrayWithObject:game];
                yearData[@(year)] = data;
            } else {
                data.games = [data.games arrayByAddingObject:game];
            }
        }
        
        for (CCPlayerYearData *yd in yearData.allValues) {
            int winCount = 0;
            for (CCGame *g in yd.games) {
                switch (g.gameResult) {
                    case Red:
                        if (g.redPlayer.playerID == p.playerID) {
                            winCount += 1;
                        }
                        break;
                    case Black:
                        if (g.blackPlayer.playerID == p.playerID) {
                            winCount += 1;
                        }
                        break;
                    default:
                        break;
                }
            }
            
            yd.winRate = (float)winCount / (float)[yd.games count];
        }

        rslt = [CCPlayerData new];
        rslt.redCount = totalRed;
        rslt.redWinCount = totalRedWin;
        rslt.redTieCount = totalRedTie;
        rslt.blackCount = totalBlack;
        rslt.blackWinCount = totalBlackWin;
        rslt.blackTieCount = totalBlackTie;
        rslt.allGames = [games copy];
        rslt.opponents = [[opponents allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CCOpponent *op1 = (CCOpponent *)obj1;
            CCOpponent *op2 = (CCOpponent *)obj2;
            
            return [op2 totalCount] > [op1 totalCount];
        }];
        
        rslt.yearData = [yearData.allValues sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            CCPlayerYearData *d1 = (CCPlayerYearData *)obj1;
            CCPlayerYearData *d2 = (CCPlayerYearData *)obj2;
            
            return d1.year > d2.year;
        }];
        
    }];
    
    [self.cache setObject:rslt forKey:@(p.playerID)];
    
    return rslt;
}

#pragma mark - Data Convertor
- (CCMatch *)matchFrom:(FMResultSet *)rs
{
    CCMatch *m = [CCMatch new];
    m.matchID = [rs intForColumnIndex:0];
    m.clz = [rs stringForColumnIndex:1];
    m.name = [rs stringForColumnIndex:2];
    
    return m;
}

- (CCPlayer *)playerFrom:(FMResultSet *)rs
{
    CCPlayer *p = [CCPlayer new];
    p.playerID = [rs intForColumnIndex:0];
    p.name = [rs stringForColumnIndex:1];
    p.accessTime = [rs intForColumnIndex:2];
    
    return p;
}

- (CCGame *)gameFrom:(FMResultSet *)rs
{
    int ci = 0;
    CCGame *g = [CCGame new];
    g.gameID = [rs intForColumnIndex:ci++];
    g.moveList = [rs stringForColumnIndex:ci++];
    g.result = [rs stringForColumnIndex:ci++];
    

    CCPlayer *redPlayer = [CCPlayer new];
    redPlayer.playerID = [rs intForColumnIndex:ci++];
    redPlayer.name = [rs stringForColumnIndex:ci++];
    g.redPlayer = redPlayer;
    
    g.redTeamName = [rs stringForColumnIndex:ci++];
        
    g.blackPlayer = [CCPlayer new];
    g.blackPlayer.playerID = [rs intForColumnIndex:ci++];
    g.blackPlayer.name = [rs stringForColumnIndex:ci++];
    
    g.blackTeamName = [rs stringForColumnIndex:ci++];
    
    CCMatch *m = [CCMatch new];
    m.matchID = [rs intForColumnIndex:ci++];
    m.clz = [rs stringForColumnIndex:ci++];
    m.name = [rs stringForColumnIndex:ci++];
    g.match = m;
    
    CCArrangement *a = [CCArrangement new];
    a.arrangementID = [rs intForColumnIndex:ci++];
    a.number = [rs stringForColumnIndex:ci++];
    a.name = [rs stringForColumnIndex:ci++];
    a.branch = [rs stringForColumnIndex:ci++];
    g.arrangement = a;
    
    g.gameType = [rs stringForColumnIndex:ci++];
    
    double timeStamp = [rs doubleForColumnIndex:ci++];
    g.playTime = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    
    g.title = [rs stringForColumnIndex:ci++];
    
    if ([rs columnCount] > ci) {
        g.moveIndex = [rs intForColumnIndex:ci++];
    }
    
    return g;
}

#pragma mark - save last state.
static NSString *LastSelfPlayKey = @"cc_last_self_play_key";
static NSString *LastPlayKey = @"cc_last_play_key";
- (CCPlayUnfinishedModel *)lastPlayModel:(BOOL)isSelfPlay
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:isSelfPlay ? LastSelfPlayKey : LastPlayKey];
    if (!data) return nil;
    
    NSError *error = nil;
    CCPlayUnfinishedModel *model = [NSKeyedUnarchiver unarchivedObjectOfClass:[CCPlayUnfinishedModel class] fromData:data error:&error];
    if (error) {
        DLog("unarchive data failed with error: %@", error);
        return nil;
    }
    
    return model;
}

- (void)saveLastPlay:(CCPlayUnfinishedModel *)model isSelfPlay:(BOOL)selfPlay
{
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model requiringSecureCoding:YES error:&error];
    if (error) {
        DLog("archive model failed with error: %@", error);
        return;
    }
    if (!data || data.length <= 0) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:selfPlay ? LastSelfPlayKey : LastPlayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearLastPlay:(BOOL)isSelfPlay
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: isSelfPlay ? LastSelfPlayKey : LastPlayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Settings
- (int)chessboardType
{
    if (!self.cbt) {
        self.cbt = [[NSUserDefaults standardUserDefaults] objectForKey:@"chessboard_type"];
    }
    
    if (!self.cbt) {
        self.cbt = @(2);
    }
    
    return [self.cbt intValue];
}

- (void)setChessboardType:(int)chessboardType
{
    self.cbt = @(chessboardType);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.cbt forKey:@"chessboard_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)autoPlayDelay
{
    if (!self.apd) {
        self.apd = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto_play_delay"];
    }
    
    if (!self.apd) {
        self.apd = @(1.5f);
    }
    
    return [self.apd floatValue];
}

- (void)setAutoPlayDelay:(float)autoPlayDelay
{
    self.apd = @(autoPlayDelay);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.apd forKey:@"auto_play_delay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)analyzaDepth
{
    if (!self.depth) {
        self.depth = [[NSUserDefaults standardUserDefaults] objectForKey:@"analyza_depth"];
    }
    
    if (!self.depth) {
        self.depth = @20;
    }
    
    return [self.depth intValue];
}

- (void)setAnalyzaDepth:(int)analyzaDepth
{
    self.depth = @(analyzaDepth);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.depth forKey:@"analyza_depth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 人机、打谱相关
- (NSString *)recordDBPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent: @"games.sqlite"];
}

- (void)saveRecord:(CCPlayRecord *)r
{
    [self.recordQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        DLog(@"try to save record: %@", r);
        NSError *error = nil;
        [db executeUpdate:@"INSERT OR IGNORE INTO `record`(color, moves, time, result, comment) VALUES(?,?,?,?,?);" values:@[@(r.computerColor), r.moveList, @(r.playTime), @(r.result), r.comment == nil ? @"" : r.comment] error:&error];
        if (error != nil) {
            DLog(@"save record failed with error: %@", error);
        }
    }];
}

- (void)removeRecord:(int)rid
{
    [self.recordQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (![db executeStatements:[NSString stringWithFormat:@"DELETE FROM `record` WHERE id=%d;", rid]]) {
            DLog(@"failed to remove record(%d) with error: %@", rid, [db lastError]);
        }
    }];
}

- (void)loadRecordAt:(int)page pageSize:(int)ps completion:(LoadRecordsCompletion)cmp;
{
    DLog("load page: %d, pageSize: %d", page, ps);
    [self.recordQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        FMResultSet *rs = [db executeQueryWithFormat:@"SELECT * FROM `record` ORDER BY time DESC LIMIT %d, %d", page * ps, ps];
        NSMutableArray *records = [NSMutableArray array];
        while([rs next]) {
            CCPlayRecord *record = [CCPlayRecord new];
            record.recordID = [rs intForColumnIndex:0];
            record.computerColor = [rs intForColumnIndex:1];
            record.moveList = [rs stringForColumnIndex:2];
            record.playTime = [rs doubleForColumnIndex:3];
            record.result = [rs intForColumnIndex:4];
            record.comment = [rs stringForColumnIndex:5];
            
            [records addObject:record];
        }
        
        CALL_BLOCK(cmp, records);
    }];
}
@end
