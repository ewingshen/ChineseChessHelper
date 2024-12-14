//
//  CCChessboardTypeSelectTableViewCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/10.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCChessboardTypeSelectTableViewCell.h"
#import "CCChesscore.h"
#import "UIView+CCFast.h"
#import "CCMaskImageView.h"

@implementation CCChessboardTypeSelectTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setImageNames:(NSArray<NSString *> *)imageNames
{
    if (_imageNames != imageNames) {
        if (!self.stackView) {
            self.stackView = [[UIStackView alloc] initWithFrame:self.contentView.bounds];
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            self.stackView.spacing = 40;
            self.stackView.alignment = UIStackViewAlignmentCenter;
            self.stackView.distribution = UIStackViewDistributionFillEqually;
            [self.contentView addSubview:self.stackView];
        } else {
            [self.stackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        _imageNames = imageNames;
        
        [imageNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CCMaskImageView *imageView = [[CCMaskImageView alloc] initWithImage:[UIImage imageNamed:obj]];
            imageView.tag = 0x110 + idx;
            
            imageView.showMask = idx != [CCChesscore core].chessboardType;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self.stackView addArrangedSubview:imageView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapAction:)];
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = YES;
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.stackView.frame = CGRectMake(10, 0, self.contentView.width - 20, self.contentView.height);
}

- (void)imageTapAction:(UIGestureRecognizer *)gesture
{
    NSInteger idx = gesture.view.tag - 0x110;
    for (UIView *v in self.stackView.subviews) {
        [(CCMaskImageView *)v setShowMask:v != gesture.view];
    }
    
    [CCChesscore core].chessboardType = (int)idx;
}

@end
