//
//  NSArray+Utils.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "NSArray+Utils.h"

@implementation NSArray (Utils)

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    if (idx < self.count) {
        return [self objectAtIndex:idx];
    }
    
    return nil;
}

- (NSArray *)filter:(BOOL (^)(id _Nonnull))block
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block
{
    NSMutableArray *rslt = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        id no = block(obj);
        if (no) {
            [rslt addObject:no];
        }
    }
    return [rslt copy];
}

- (id)reduce:(id  _Nonnull (^)(id _Nonnull, id _Nonnull))block initialValue:(nonnull id)iv
{
    for (id obj in self) {
        iv = block(iv, obj);
    }
    return iv;
}

- (id)first:(BOOL (^)(id _Nonnull))block
{
    for (id obj in self) {
        if (block(obj)) {
            return obj;
        }
    }
    
    return nil;
}

- (NSUInteger)firstIndex:(BOOL (^)(id _Nonnull))block
{
    for(int i = 0; i < self.count; i++) {
        if (block(self[i])) {
            return i;
        }
    }
    
    return NSNotFound;
}

@end


@implementation NSMutableArray (Utils)

- (void)safeAddObject:(id)obj
{
    if (obj) {
        [self addObject:obj];
    }
}

@end
