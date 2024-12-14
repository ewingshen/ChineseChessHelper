//
//  CCMoveItem.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/4.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCMoveItem.h"
#import "CCChessUtil.h"

@implementation CCMoveItem

+ (instancetype)moveWitMainType:(CCChessmanType)mt context:(nonnull NSNumber *)mc from:(CCPosition)fp to:(CCPosition)tp
{
    return [self moveWitMainType:mt mainContext:mc from:fp to:tp eated:CCChessmanType_None eatedContext:nil];
}

+ (instancetype)moveWitMainType:(CCChessmanType)mt mainContext:(nonnull NSNumber *)mc from:(CCPosition)fp to:(CCPosition)tp eated:(CCChessmanType)emt eatedContext:(NSNumber * _Nullable)ec
{
    CCMoveItem *mi = [CCMoveItem new];
    mi.mainChessman = mt;
    mi.from = fp;
    mi.to = tp;
    mi.mainCtx = mc;
    mi.eatedChessman = emt;
    mi.eatedCtx = ec;
   
    return mi;
}

- (BOOL)hasEated
{
    return self.eatedChessman != CCChessmanType_None;
}

- (NSString *)Fen
{
    return [NSString stringWithFormat:@"%@%@", [CCChessUtil FenFromPosition:self.from], [CCChessUtil FenFromPosition:self.to]];
}
@end
