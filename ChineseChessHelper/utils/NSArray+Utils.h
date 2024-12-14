//
//  NSArray+Utils.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (Utils)

- (NSArray<ObjectType> *)filter:(BOOL(^)(ObjectType item))block;
- (NSArray *)map:(id _Nullable(^)(ObjectType item))block;
- (id)reduce:(id(^)(id partitialValue, ObjectType item))block initialValue:(id)iv;

- (ObjectType _Nullable)first:(BOOL(^)(ObjectType item))block;
- (NSUInteger)firstIndex:(BOOL(^)(ObjectType item))block;

@end

@interface NSMutableArray (Utils)

- (void)safeAddObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
