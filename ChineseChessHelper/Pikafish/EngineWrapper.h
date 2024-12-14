//
//  EngineWrapper.h
//  PikafishObjc
//
//  Created by ewing on 2024/11/23.
//

#import <Foundation/Foundation.h>
#import "PikafishModels.h"

NS_ASSUME_NONNULL_BEGIN

@class EngineWrapper;
@protocol EngineWrapperDelegate <NSObject>

@optional
- (void)wrapper:(EngineWrapper *)pf onVerifyNetworks:(NSString *)info;
- (void)wrapper:(EngineWrapper *)pf onUpdateNoMoves:(PikafishShortInfo *)info;
- (void)wrapper:(EngineWrapper *)pf bestMove:(NSString *)bm ponder:(NSString *)p;
- (void)wrapper:(EngineWrapper *)pf onIter:(PikafishIterInfo *)info;
- (void)wrapper:(EngineWrapper *)pf onUpdateFull:(PikafishFullInfo *)info;

@end

@interface EngineWrapper : NSObject

+ (instancetype)shared;

@property (nonatomic, weak) id<EngineWrapperDelegate> delegate;

@property (nonatomic, copy, nullable) NSString *currentFen;
@property (nonatomic, copy, nullable) NSString *bestMove;
@property (nonatomic, copy, nullable) NSString *ponder;

- (void)test;

- (unsigned int)maxThreadCount;

- (void)setPonderMode:(BOOL)enablePonder;
- (void)setThreadCount:(int)tc;
- (void)setPVCount:(int)c;

- (void)position:(NSString *)fen currentMove:(NSString * _Nullable)move goTime:(double)time goDepth:(int)depth;
- (BOOL)checkMoveLegal:(NSString *)moveFen atPosition:(NSString *)fen;

- (void)goDepth:(int)depth;
- (void)goTime:(float)time;

- (void)start;
- (void)stop;

- (void)goPonder:(NSString *)positionFen depth:(int)d;

////
/// for private
- (void)notifyDelegateVerifyNetworks:(NSString *)str;
- (void)notifyDelegateUpdateNoMoves:(PikafishShortInfo *)info;
- (void)notifyDelegateUpdateFull:(PikafishFullInfo *)info;
- (void)notifyDelegateIter:(PikafishIterInfo *)info;
- (void)notifyDelegateBestMove:(NSString *)bm ponder:(NSString *)ponder;

@end

NS_ASSUME_NONNULL_END
