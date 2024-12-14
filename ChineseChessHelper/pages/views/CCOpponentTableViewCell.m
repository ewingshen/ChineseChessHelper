//
//  CCOpponentTableViewCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/18.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCOpponentTableViewCell.h"
#import "UIView+CCFast.h"
#import "CCGameCountView.h"

@interface CCOpponentTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) CCGameCountView *countView;

@end

@implementation CCOpponentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.adjustsFontSizeToFitWidth = true;
    [self.contentView addSubview:self.nameLabel];
    
    self.countView = [[CCGameCountView alloc] initWithFrame:CGRectZero title:@""];
    [self.contentView addSubview:self.countView];
}

- (void)update:(CCOpponent *)opp
{
    self.nameLabel.text = opp.player.name;
    [self.countView updateWin:opp.redWinCount + opp.blackWinCount
                          tie:opp.redTieCount + opp.blackTieCount
                         lose:opp.redLoseCount + opp.blackLoseCount];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(16, (self.contentView.height - 30) * 0.5, 50.0f, 30);
    self.countView.frame = CGRectMake(self.nameLabel.right + 4, (self.contentView.height - 30) * 0.5, self.contentView.width - self.nameLabel.right - 20, 30);
}
@end
