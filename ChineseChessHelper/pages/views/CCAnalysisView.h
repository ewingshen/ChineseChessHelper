//
//  CCAnalysisView.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/4.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCChessboard.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCAnalysisView : UIView

- (instancetype)initWithBoardSize:(CGSize)size
                     initialPhase:(NSData *)phase
                         moveList:(NSString *)ml
                     currentIndex:(int)idx
                   popOutPosition:(CGPoint)p;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) CCChessBoard *board;
@property (nonatomic, copy) EmptyAction dismissCompletion;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
