//
//  NSMutableDictionary+CCUtil.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/4.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary<KeyType, ObjectType> (CCUtil)

- (void)incOneForKey:(KeyType)key;
- (void)decOneForKey:(KeyType)key;

- (void)incOneForKey:(id)key increment:(NSNumber *)cnt;
@end

NS_ASSUME_NONNULL_END
