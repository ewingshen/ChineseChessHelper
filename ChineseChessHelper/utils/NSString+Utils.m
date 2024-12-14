//
//  NSString+Utils.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/26.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)localized
{
    return NSLocalizedString(self, "");
}

@end
