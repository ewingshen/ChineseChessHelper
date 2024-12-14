//
//  CCGameCountView.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/24.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCGameCountView.h"
#import "UIView+CCFast.h"

@interface CCGameCountView ()

@property (nonatomic, assign) int wc;
@property (nonatomic, assign) int tc;
@property (nonatomic, assign) int lc;

@property (nonatomic, strong) UIView *labelContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *winCountLabel;
@property (nonatomic, strong) UILabel *tieCountLabel;
@property (nonatomic, strong) UILabel *loseCountLabel;

@end
//kColorWith16RGB(0xe3170d), kColorWith16RGB(0x999999), kColorWith16RGB(0x333333),
@implementation CCGameCountView

- (instancetype)initWithFrame:(CGRect)frame title:(nonnull NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [UILabel new];
        self.titleLabel.text = title;
        self.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.titleLabel sizeToFit];
        [self addSubview:self.titleLabel];
        
        self.labelContainer = [UIView new];
        self.labelContainer.layer.cornerRadius = 8;
        self.labelContainer.layer.masksToBounds = YES;
        if (@available(iOS 13.0, *)) {
            self.labelContainer.layer.cornerCurve = kCACornerCurveContinuous;
        }
        [self addSubview:self.labelContainer];
        
        self.winCountLabel = [self createLabel];
        self.winCountLabel.backgroundColor = kColorWith16RGB(0xe3170d);
        [self.labelContainer addSubview:self.winCountLabel];
        
        self.tieCountLabel = [self createLabel];
        self.tieCountLabel.backgroundColor = kColorWith16RGB(0x999999);
        [self.labelContainer addSubview:self.tieCountLabel];
        
        self.loseCountLabel = [self createLabel];
        self.loseCountLabel.backgroundColor = kColorWith16RGB(0x333333);
        [self.labelContainer addSubview:self.loseCountLabel];
    }
    return self;
}

- (UILabel *)createLabel
{
    UILabel *l = [UILabel new];
    l.font = [UIFont systemFontOfSize:11];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.adjustsFontSizeToFitWidth = true;
    l.numberOfLines = 0;
    return l;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, (self.height - self.titleLabel.height) * 0.5, self.titleLabel.width, self.titleLabel.height);
    
    CGFloat spacing = self.titleLabel.width > 0 ? 6.0f : 0.0f;
    CGFloat ch = self.height;
    CGFloat leftWidth = self.width - self.titleLabel.width - spacing;
    CGFloat total = self.wc + self.tc + self.lc;
    
    if (total == 0) {
        self.labelContainer.frame = CGRectZero;
        self.winCountLabel.frame = CGRectZero;
        self.tieCountLabel.frame = CGRectZero;
        self.loseCountLabel.frame = CGRectZero;
    } else {
        self.labelContainer.frame = CGRectMake(self.titleLabel.right + spacing, (self.height - ch) * 0.5, leftWidth, ch);
        self.winCountLabel.frame = CGRectMake(0, 0, leftWidth * self.wc / total, ch);
        self.tieCountLabel.frame = CGRectMake(self.winCountLabel.right, 0, leftWidth * self.tc / total, ch);
        self.loseCountLabel.frame = CGRectMake(self.tieCountLabel.right, 0, leftWidth * self.lc / total, ch);
    }
}

- (void)updateWin:(int)wc tie:(int)tc lose:(int)lc
{
    CGFloat total = wc + tc + lc;
    CGFloat wr = wc / total;
    CGFloat tr = tc / total;
    CGFloat lr = lc / total;
    
    self.wc = wc;
    self.tc = tc;
    self.lc = lc;
    
    self.winCountLabel.text = [NSString stringWithFormat:@"%d胜(%.1f%%)", wc, wr * 100];
    [self.winCountLabel sizeToFit];
    self.tieCountLabel.text = [NSString stringWithFormat:@"%d和(%.1f%%)", tc, tr * 100];
    [self.tieCountLabel sizeToFit];
    self.loseCountLabel.text = [NSString stringWithFormat:@"%d负(%.1f%%)", lc, lr * 100];
    [self.loseCountLabel sizeToFit];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
