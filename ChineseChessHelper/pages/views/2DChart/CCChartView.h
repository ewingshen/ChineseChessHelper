//
//  CCChartView.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/10.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class CC2DEntry;

@interface CCChartView : UIView

@property (nonatomic, copy) void(^selecteEntry)(CC2DEntry *entry);
@property (nonatomic, strong) NSArray<CC2DEntry *> *entries;

@property (nonatomic, copy, nullable) NSString *titile;

@end

NS_ASSUME_NONNULL_END
