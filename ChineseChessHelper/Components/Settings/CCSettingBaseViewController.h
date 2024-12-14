//
//  CCSettingBaseViewController.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCViewController.h"
#import "CCSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCSettingBaseViewController : CCViewController

@property (nonatomic, strong, readonly) NSMutableArray<CCSettingItem *> *data;
@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)setupData;
- (void)update;

@end

NS_ASSUME_NONNULL_END
