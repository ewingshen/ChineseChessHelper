//
//  CCItemPickViewController.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/8/3.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCItemPickViewController : CCViewController

- (instancetype)initWithItems:(NSArray<NSString *> *)items specialItems:(NSArray<NSString *> * _Nullable)sitems specialTitle:(NSString * _Nullable)st;

@property (nonatomic, copy) void(^doneAction)(NSInteger selectedIndex);
@property (nonatomic, copy) void(^specialDoneAction)(NSInteger selectedIndex);

@end

NS_ASSUME_NONNULL_END
