//
//  PikafishWrapper.m
//  PikafishObjc
//
//  Created by ewing on 2024/11/23.
//

#import "EngineWrapper.h"
#import "uci.h"
#import "engine.h"
#import "bitboard.h"
#import "position.h"
#import <sys/sysctl.h>
#import "movegen.h"

using namespace Stockfish;

static NSString *startFen = @"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR";

@interface PikafishFullInfo (initial)
- (instancetype)init:(const Stockfish::Search::InfoFull&)info;
@end

@interface PikafishShortInfo (initial)
- (instancetype)init:(const Stockfish::Search::InfoShort&)info;
@end

@interface PikafishIterInfo (initial)
- (instancetype)init:(const Stockfish::Search::InfoIteration&)info;
@end

void onVerifyNetworks(std::string_view str) {
    [[EngineWrapper shared] notifyDelegateVerifyNetworks:c2s(str)];
}

void onUpdateNoMoves(const Engine::InfoShort& info) {
    DLog(@"updateNoMoves: %d, %@", info.depth, c2s(UCIEngine::format_score(info.score)));
    
    PikafishShortInfo *si = [[PikafishShortInfo alloc] init:info];
    [[EngineWrapper shared] notifyDelegateUpdateNoMoves:si];
}

void onUpdateFull(const Engine::InfoFull& info) {
    NSMutableString *logInfo = [NSMutableString string];
    [logInfo appendFormat:@"depth: %d\n", info.depth];
    [logInfo appendFormat:@"score: %@\n", c2s(UCIEngine::format_score(info.score))];
    [logInfo appendFormat:@"selDepth: %d\n", info.selDepth];
    [logInfo appendFormat:@"multiPV: %ld\n", info.multiPV];
    [logInfo appendFormat:@"wdl: %@\n", c2s(info.wdl)];
    [logInfo appendFormat:@"bound: %@\n", c2s(info.bound)];
    [logInfo appendFormat:@"time(ms): %ld\n", info.timeMs];
    [logInfo appendFormat:@"nodes: %ld\n", info.nodes];
    [logInfo appendFormat:@"nps: %ld\n", info.nps];
    [logInfo appendFormat:@"tbHits: %ld\n", info.tbHits];
    [logInfo appendFormat:@"pv: %@\n", c2s(info.pv)];
    [logInfo appendFormat:@"hashfull: %d\n", info.hashfull];
    
    DLog(@"%@", logInfo);
    
    PikafishFullInfo *fi = [[PikafishFullInfo alloc] init:info];
    [[EngineWrapper shared] notifyDelegateUpdateFull:fi];
}

void onIter(const Engine::InfoIter& info) {
    PikafishIterInfo *ii = [[PikafishIterInfo alloc] init:info];
    [[EngineWrapper shared] notifyDelegateIter:ii];
}

void onBestMove(std::string_view bestmove, std::string_view ponder) {
    [[EngineWrapper shared] notifyDelegateBestMove:c2s(bestmove) ponder:c2s(ponder)];
}

@implementation EngineWrapper
{
    Stockfish::UCIEngine *uci;
    unsigned int ncpu;
    bool _enablePonder;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static EngineWrapper *singleton;
    dispatch_once(&onceToken, ^{
        singleton = [EngineWrapper new];
    });
    return singleton;
}

- (instancetype)init {
    if (self = [super init]) {
        Bitboards::init();
        Position::init();
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pikafish" ofType:@"nnue"];
        uci = new UCIEngine(std::string(filePath.UTF8String));
        
        uci->engine.set_on_iter(onIter);
        uci->engine.set_on_verify_networks(onVerifyNetworks);
        uci->engine.set_on_bestmove(onBestMove);
        uci->engine.set_on_update_no_moves(onUpdateNoMoves);
        uci->engine.set_on_update_full(onUpdateFull);
        
        uci->execute("uci");
        uci->execute("setoption name UCI_ShowWDL value true");
        
        size_t len = sizeof(ncpu);
        sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
        DLog(@"ncpu: %d", ncpu);
    }
    return self;
}

- (void)test {
    uci->execute("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w 0 1 moves h2e2");
    uci->execute("go depth 10");
}

- (void)setPonderMode:(BOOL)enablePonder
{
    _enablePonder = enablePonder;
    uci->execute([NSString stringWithFormat:@"setoption name Ponder value %@", enablePonder ? @"true" : @"false"].UTF8String);
}

- (void)setThreadCount:(int)tc
{
    uci->execute([NSString stringWithFormat:@"setoption name Threads value %d", tc].UTF8String);
}

- (void)setPVCount:(int)c
{
    uci->execute([NSString stringWithFormat:@"setoption name MultiPV value %d", c].UTF8String);
}

- (void)position:(NSString *)fen currentMove:(NSString *)move goTime:(double)time goDepth:(int)depth
{
    DLog(@"fen: %@", fen);
    DLog(@"move: %@", move);
    DLog(@"goTime: %f, goDepth: %d", time, depth);
    
//    if ([move isEqualToString:self.ponder] && _enablePonder) {
//        uci->execute("ponderhit");
//        return;
//    }
    
    uci->execute(fen.UTF8String);
    if (time > 0) {
        [self goTime:time];
    } else {
        [self goDepth:depth];
    }
}

- (BOOL)checkMoveLegal:(NSString *)moveFen atPosition:(NSString *)fen
{
    return uci->check_move(fen.UTF8String, moveFen.UTF8String);
}

- (void)goDepth:(int)depth
{
    uci->execute([NSString stringWithFormat:@"go depth %d", depth].UTF8String);
}

- (void)goTime:(float)time
{
    uci->execute([NSString stringWithFormat:@"go movetime %d", (int)(time*1000)].UTF8String);
}

- (void)start
{
    uci->execute("ucinewgame");
}

- (void)stop
{
    uci->execute("stop");
}

- (unsigned int)maxThreadCount
{
    return ncpu;
}

- (void)goPonder:(NSString *)positionFen depth:(int)d
{
    uci->execute("stop");
    uci->execute(positionFen.UTF8String);
    uci->execute([NSString stringWithFormat:@"go depth %d", d].UTF8String);
}

#pragma mark - Process Delegate
- (void)notifyDelegateVerifyNetworks:(NSString *)str
{
    if ([self.delegate respondsToSelector:@selector(wrapper:onVerifyNetworks:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wrapper:self onVerifyNetworks:str];
        });
    }
}

- (void)notifyDelegateUpdateNoMoves:(PikafishShortInfo *)info
{
    if ([self.delegate respondsToSelector:@selector(wrapper:onUpdateNoMoves:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wrapper:self onUpdateNoMoves:info];
        });
    }
}

- (void)notifyDelegateUpdateFull:(PikafishFullInfo *)info
{
    if ([self.delegate respondsToSelector:@selector(wrapper:onUpdateFull:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wrapper:self onUpdateFull:info];
        });
    }
}

- (void)notifyDelegateIter:(PikafishIterInfo *)info
{
    if ([self.delegate respondsToSelector:@selector(wrapper:onIter:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wrapper:self onIter:info];
        });
    }
}

- (void)notifyDelegateBestMove:(NSString *)bm ponder:(NSString *)ponder
{
    self.bestMove = bm;
    self.ponder = ponder;
    if ([self.delegate respondsToSelector:@selector(wrapper:bestMove:ponder:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wrapper:self bestMove:bm ponder:ponder];
        });
    }
}
@end
