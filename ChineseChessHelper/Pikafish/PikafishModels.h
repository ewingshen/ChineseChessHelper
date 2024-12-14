//
//  PikafishModels.h
//  PikafishObjc
//
//  Created by ewing on 2024/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define c2s(str) ((str).data() != nil ? [NSString stringWithUTF8String:(str).data()] : @"")

@interface PikafishShortInfo : NSObject
/// 搜索深度
@property (nonatomic, assign) int depth;
/// 分数：cp 表示子力分数 mate 表示多少步绝杀.
@property (nonatomic, strong) NSString *score;

@end

@interface PikafishFullInfo : PikafishShortInfo

/// 剪枝深度
@property (nonatomic, assign) int selDepth;
/// 计算分支数，默认只有一个最佳分支
@property (nonatomic, assign) long multiPV;
/// w:赢 d：和 l：输的概率
@property (nonatomic, copy) NSString *wdl;
/// bound 表示当前局面评估的范围限制（边界），通常在引擎未能给出确切评估值时使用。
@property (nonatomic, copy) NSString *bound;
/// 用时
@property (nonatomic, assign) long timeMs;
/// 搜索节点数
@property (nonatomic, assign) long nodes;
/// nodes per second
@property (nonatomic, assign) long nps;
/// 引擎访问开局库或终结表库（tablebases）的次数。
@property (nonatomic, assign) long tbHits;
/// 最佳分支
@property (nonatomic, copy) NSString *pv;
/// 哈希表的使用率
@property (nonatomic, assign) int hashfull;

// 以下字段不是来自引擎，用于分析展示使用.
@property (nonatomic, copy) NSString *pvMoveList;
@property (nonatomic, strong) NSArray<NSString *> *pvDisplayList;
@property (nonatomic, assign) NSData *startPhase;
@property (nonatomic, assign) int startMoveIndex;
@property (nonatomic, copy) NSString *score4Display;

- (BOOL)getWinRate:(float *)w drawRate:(float *)d loseRate:(float *)l;

- (NSString *)displayScore:(BOOL)computerIsRed;

@end

@interface PikafishIterInfo : NSObject

@property (nonatomic, assign) int depth;
@property (nonatomic, copy) NSString *curMove;
/// 当前正在搜索的着法序号
@property (nonatomic, assign) long curMoveNumber;

@end

NS_ASSUME_NONNULL_END
