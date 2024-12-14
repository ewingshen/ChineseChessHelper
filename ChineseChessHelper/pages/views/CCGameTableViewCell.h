//
//  CCGameTableViewCell.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/27.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCGameTableViewCell : UITableViewCell

@property (nonatomic, strong) CCGame *game;
@property (nonatomic, strong) CCPlayRecord *record;

- (NSString *)title;

@end

NS_ASSUME_NONNULL_END
