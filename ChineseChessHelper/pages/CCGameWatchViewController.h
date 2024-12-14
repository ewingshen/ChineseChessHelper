//
//  CCGameWatchViewController.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCViewController.h"
#import "ChessDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCGameWatchViewController : CCViewController

- (instancetype)initWithGame:(CCGame *)game;
- (instancetype)initWithRecord:(CCPlayRecord *)record;
@end

NS_ASSUME_NONNULL_END
