//
//  CCMoveListView.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/6.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCMoveListView : UIView

@property (nonatomic, strong) NSArray<NSString *> *translatedMoves;
@property (nonatomic, assign, readonly) int currentIndex;
@property (nonatomic, copy) void(^moveSelectAction)(int moveIndex);

- (void)updateSelectedIndex:(int)ci;

@end

NS_ASSUME_NONNULL_END
