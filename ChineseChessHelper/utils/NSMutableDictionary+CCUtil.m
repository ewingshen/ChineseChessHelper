//
//  NSMutableDictionary+CCUtil.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/4.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "NSMutableDictionary+CCUtil.h"

@implementation NSMutableDictionary (CCUtil)

- (void)incOneForKey:(id<NSCopying>)key
{
    id n = [self objectForKey:key];
    
    if (n) {
        assert([n isKindOfClass:[NSNumber class]]);
        [self setObject:@([(NSNumber *)n intValue] + 1) forKey:key];
    } else {
        [self setObject:@(1) forKey:key];
    }
}

- (void)decOneForKey:(id)key
{
    id n = [self objectForKey:key];
    assert([n isKindOfClass:[NSNumber class]]);
    
    if (n) {
        [self setObject:@([(NSNumber *)n intValue] - 1) forKey:key];
    }
}

- (void)incOneForKey:(id)key increment:(NSNumber *)cnt
{
    if ([cnt intValue] == 0) {
        return;
    }
    
    NSNumber *n = [self objectForKey:key];
    if (n) {
        [self setObject:@([n intValue] + [cnt intValue]) forKey:key];
    } else {
        [self setObject:cnt forKey:key];
    }
}
@end
