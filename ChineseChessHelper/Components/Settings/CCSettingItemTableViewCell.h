//
//  CCSettingItemTableViewCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSettingItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCSettingItemTableViewCell : UITableViewCell

@property (nonatomic, strong, setter=bind:, nullable) CCSettingItem *item;

@end

NS_ASSUME_NONNULL_END
