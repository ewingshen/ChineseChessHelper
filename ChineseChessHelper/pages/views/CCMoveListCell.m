//
//  CCMoveListCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/2.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCMoveListCell.h"

@implementation CCMoveListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.font = self.textLabel.font;
        self.detailTextLabel.textColor = self.textLabel.textColor;
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)updateTextColor:(UIColor *)color
{
    self.textLabel.textColor = color;
    self.detailTextLabel.textColor = color;
}

- (void)updateTitle:(NSString *)title move:(NSString *)m
{
    self.textLabel.text = title;
    self.detailTextLabel.text = m;
    
    [self setNeedsUpdateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout 
{
    return YES;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.textLabel.superview == nil || self.detailTextLabel.superview == nil) {
        return;
    }
    
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.textLabel.superview).offset(4);
        make.centerY.equalTo(self.textLabel.superview);
        make.width.mas_equalTo(20);
    }];
    
    [self.detailTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.detailTextLabel.superview);
        make.leading.equalTo(self.textLabel.mas_trailing).offset(2);
    }];
}
@end
