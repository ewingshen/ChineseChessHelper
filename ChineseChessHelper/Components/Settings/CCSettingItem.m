//
//  CCSettingItem.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCSettingItem.h"

@implementation CCSettingItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.style = UITableViewCellStyleValue1;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.detailType = CCSettingItemDetailType_Text;
        self.height = 60;
        self.textFieldAlignment = NSTextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
