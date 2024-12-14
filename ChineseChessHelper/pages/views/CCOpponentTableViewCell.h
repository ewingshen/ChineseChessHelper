//
//  CCOpponentTableViewCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/18.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCOpponentTableViewCell : UITableViewCell

- (void)update:(CCOpponent *)opp;

@end

NS_ASSUME_NONNULL_END
