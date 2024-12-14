//
//  CC2DChartCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/10.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CC2DChartCell.h"
#import "UIView+CCFast.h"
#import "CC2DEntry.h"

@interface CC2DChartCell ()

@property (nonatomic, strong) UILabel *xValueLabel;
@property (nonatomic, strong) UILabel *yValueLabel;
@property (nonatomic, strong) UIView *bar;

@property (nonatomic, strong) CC2DEntry *entry;

@end

@implementation CC2DChartCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.xValueLabel = [[UILabel alloc] init];
        self.xValueLabel.font = [UIFont systemFontOfSize:12];
        self.xValueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.xValueLabel];
        
        self.yValueLabel = [[UILabel alloc] init];
        self.yValueLabel.font = [UIFont systemFontOfSize:11];
        self.yValueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.yValueLabel];
        
        self.bar = [[UIView alloc] init];
        self.bar.backgroundColor = [UIColor systemBlueColor];
        [self.contentView addSubview:self.bar];
        
        
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return true;
}

- (void)updateConstraints
{
    [self.yValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.bar.mas_top);
    }];
    
    [self.bar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(self.bar.height);
        make.bottom.equalTo(self.xValueLabel.mas_top).offset(-2);
    }];
    
    [self.xValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)bind:(CC2DEntry *)entry
{
    self.entry = entry;
    
    self.xValueLabel.text = entry.x;
    [self.xValueLabel sizeToFit];
    self.yValueLabel.text = entry.y;
    [self.yValueLabel sizeToFit];
    
    CGFloat maxBarHeight = self.contentView.height - self.xValueLabel.height - self.yValueLabel.height - 2;
    self.bar.height = maxBarHeight * entry.height;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}
@end
