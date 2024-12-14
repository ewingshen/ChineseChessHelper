//
//  CCMaskImageView.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/10.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCMaskImageView.h"
#import "UIView+CCFast.h"

#define MARGIN (10)

@interface CCMaskImageView ()

@property (nonatomic, strong) UIView *innerMaskView;
@property (nonatomic, strong) UIImageView *checkedImageView;

@end

@implementation CCMaskImageView

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        self.innerMaskView = [UIView new];
        self.innerMaskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.innerMaskView];
        
        self.checkedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game_type_checked"]];
        self.checkedImageView.hidden = YES;
        [self addSubview:self.checkedImageView];
    }
    
    return self;
}

- (void)setShowMask:(BOOL)showMask
{
    self.innerMaskView.hidden = !showMask;
    self.checkedImageView.hidden = showMask;
}

- (BOOL)showMask
{
    return !self.innerMaskView.hidden;
}

- (void)setMaskColor:(UIColor *)maskColor
{
    self.innerMaskView.backgroundColor = maskColor;
}

- (UIColor *)maskColor
{
    return self.innerMaskView.backgroundColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.innerMaskView.frame = self.bounds;
    self.checkedImageView.frame = CGRectMake(MARGIN, MARGIN, 23, 23);
}

@end
