//
//  CCGameStatisticsTableViewCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/17.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCPlayerData;
NS_ASSUME_NONNULL_BEGIN

@interface CCGameStatisticsTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^selectedYear)(NSInteger year);

- (void)update:(CCPlayerData *)data;

@end

NS_ASSUME_NONNULL_END
