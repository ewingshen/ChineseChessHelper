//
//  PikafishModels.m
//  PikafishObjc
//
//  Created by ewing on 2024/11/26.
//

#import "PikafishModels.h"
#import "uci.h"

@implementation PikafishShortInfo

- (instancetype)init:(const Stockfish::Search::InfoShort&)info
{
    if (self = [super init]) {
        self.depth = info.depth;
        self.score = c2s(Stockfish::UCIEngine::format_score(info.score));
    }
    return self;
}

@end

@implementation PikafishFullInfo

- (instancetype)init:(const Stockfish::Search::InfoFull&)info
{
    if (self = [super init:info]) {
        self.selDepth = info.selDepth;
        self.multiPV = info.multiPV;
        self.wdl = c2s(info.wdl);
        self.bound = c2s(info.bound);
        self.timeMs = info.timeMs;
        self.nodes = info.nodes;
        self.nps = info.nps;
        self.tbHits = info.tbHits;
        self.pv = c2s(info.pv);
        self.hashfull = info.hashfull;
    }
    return self;
}

- (BOOL)getWinRate:(nonnull float *)w drawRate:(nonnull float *)d loseRate:(nonnull float *)l
{
    if (self.wdl.length == 0) return false;
    
    NSArray<NSString *> *rates = [self.wdl componentsSeparatedByString:@" "];
    if (rates.count != 3) return false;
    
    *w = [rates[0] intValue];
    *d = [rates[1] intValue];
    *l = [rates[2] intValue];
    
    return true;
}

- (NSString *)displayScore:(BOOL)computerIsRed
{
    NSString *rslt = nil;
    
    if ([self.score containsString:@"cp"]) {
        int score = [[[self.score stringByReplacingOccurrencesOfString:@"cp" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
        if (!computerIsRed) {
            score = -score;
        }
        rslt = [NSString stringWithFormat:@"%d", score];
    } else {
        NSString *step = [self.score stringByReplacingOccurrencesOfString:@"mate" withString:@""];
        step = [step stringByReplacingOccurrencesOfString:@"-" withString:@""];
        step = [step stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ((computerIsRed && ![self.score containsString:@"-"])
            || (!computerIsRed && [self.score containsString:@"-"])) {
            rslt = [NSString stringWithFormat:@"红方%@步杀".localized, step];
        } else {
            rslt = [NSString stringWithFormat:@"黑方%@步杀".localized, step];
        }
    }
    
    return rslt;
}

@end


@implementation PikafishIterInfo

- (instancetype)init:(const Stockfish::Search::InfoIteration&)info
{
    if (self = [super init]) {
        self.depth = info.depth;
        self.curMove = c2s(info.currmove);
        self.curMoveNumber = info.currmovenumber;
    }
    return self;
}

@end
