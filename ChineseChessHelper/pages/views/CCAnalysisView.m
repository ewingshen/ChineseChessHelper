//
//  CCAnalysisView.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/4.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCAnalysisView.h"
#import "CCChessCore.h"
#import "UIView+CCFast.h"

@interface CCAnalysisView ()

@property (nonatomic, assign) CGPoint bornPoint;

@end

@implementation CCAnalysisView

- (instancetype)initWithBoardSize:(CGSize)size
                     initialPhase:(NSData *)phase
                         moveList:(NSString *)ml
                     currentIndex:(int)idx
                   popOutPosition:(CGPoint)p
{
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self.bgView addGestureRecognizer:tap];
        [self addSubview:self.bgView];
        
        self.board = [[CCChessBoard alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.board.mode = CCChessboardMode_Watch;
        self.board.initialPhase = phase;
        self.board.moveList = ml;
        self.board.currentMoveIndex = idx;
        self.board.center = p;
        [self addSubview:self.board];
        
        self.bornPoint = p;
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout 
{
    return true;
}

- (void)updateConstraints
{
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)show
{
    [[UIView keyWindow] addSubview:self];
    self.board.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.25 animations:^{
        self.board.transform = CGAffineTransformIdentity;
        self.board.center = self.center;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(autoPlayNext) withObject:nil afterDelay:[CCChesscore core].autoPlayDelay];
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.board.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.board.center = self.bornPoint;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        CALL_BLOCK(self.dismissCompletion)
    }];
}

- (void)autoPlayNext
{
    if (self.board.currentMoveIndex < self.board.moveList.length / 4) {
        [self.board moveNext];
    }
    
    if (self.board.currentMoveIndex < self.board.moveList.length / 4) {
        [self performSelector:@selector(autoPlayNext) withObject:nil afterDelay:[CCChesscore core].autoPlayDelay];
    }
}
@end
