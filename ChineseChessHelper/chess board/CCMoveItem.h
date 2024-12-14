//
//  CCMoveItem.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/4.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCChessmanDataStructure.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCMoveItem : NSObject

+ (instancetype)moveWitMainType:(CCChessmanType)mt context:(NSNumber *)mc from:(CCPosition)fp to:(CCPosition)tp;
+ (instancetype)moveWitMainType:(CCChessmanType)mt mainContext:(NSNumber *)mc from:(CCPosition)fp to:(CCPosition)tp eated:(CCChessmanType)emt eatedContext:(NSNumber * _Nullable)ec;

@property (nonatomic, assign) CCChessmanType mainChessman;
@property (nonatomic, strong) NSNumber *mainCtx;
@property (nonatomic, assign) CCPosition from;
@property (nonatomic, assign) CCPosition to;

@property (nonatomic, assign) CCChessmanType eatedChessman;
@property (nonatomic, strong) NSNumber *eatedCtx;

- (BOOL)hasEated;

- (NSString *)Fen;

@end

NS_ASSUME_NONNULL_END
