//
//  CCGameTableViewCell.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/27.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCGameTableViewCell.h"
#import "UIView+CCFast.h"

@interface CCGameTableViewCell ()

@property (nonatomic, strong) UILabel *matchLabel;
@property (nonatomic, strong) UILabel *redPlayerNameLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *blackPlayerNameLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CCGameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.matchLabel = [UILabel new];
    self.matchLabel.font = [UIFont systemFontOfSize:12];
    self.matchLabel.textColor = kColorWith16RGB(0x999999);
    self.matchLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.matchLabel];
    
    self.redPlayerNameLabel = [self createPlayerLabel];
    [self.contentView addSubview:self.redPlayerNameLabel];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultLabel.font = LABEL_FONT(14.0);
    [self.contentView addSubview:self.resultLabel];
    
    self.blackPlayerNameLabel = [self createPlayerLabel];
    [self.contentView addSubview:self.blackPlayerNameLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.textColor = kColorWith16RGB(0x999999);
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.dateLabel];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
}

- (UILabel *)createPlayerLabel
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
    l.font = LABEL_FONT(18);
    l.textColor = [UIColor blackColor];
    
    return l;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.matchLabel.frame = CGRectMake(12, 8, self.contentView.width - 24, self.matchLabel.height);
    const CGFloat padding = 20;
    
    self.resultLabel.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    self.redPlayerNameLabel.frame = CGRectMake(self.resultLabel.left - self.redPlayerNameLabel.width - padding, (self.contentView.height - self.redPlayerNameLabel.height) * 0.5, self.redPlayerNameLabel.width, self.redPlayerNameLabel.height);
    self.blackPlayerNameLabel.frame = CGRectMake(self.resultLabel.right + padding, (self.contentView.height - self.blackPlayerNameLabel.height) * 0.5, self.blackPlayerNameLabel.width, self.blackPlayerNameLabel.height);
    self.dateLabel.frame = CGRectMake(self.contentView.width - self.dateLabel.width - 15, self.contentView.height - self.dateLabel.height - 8, self.dateLabel.width, self.dateLabel.height);
    
    self.titleLabel.frame = CGRectMake(12, 12, self.contentView.width - 24, self.contentView.height - 24);
}

- (void)setGame:(CCGame *)game
{
    if (_game != game) {
        _game = game;
        
        if ([game.match.clz hasPrefix:@"象棋谱大全-古谱"]) {
            self.titleLabel.text = game.title;
            
            self.matchLabel.hidden = YES;
            self.redPlayerNameLabel.hidden = YES;
            self.blackPlayerNameLabel.hidden = YES;
            self.dateLabel.hidden = YES;
            self.resultLabel.hidden = YES;
            self.titleLabel.hidden = NO;
        } else {
            self.matchLabel.text = game.match.name;
            self.redPlayerNameLabel.text = game.redPlayer.name;
            if ([game.result isEqualToString:@"和棋"]) {
                self.resultLabel.text = @"和".localized;
                self.resultLabel.textColor = kColorWith16RGB(0x999999);
            } else if ([game.result isEqualToString:@"黑胜"]) {
                self.resultLabel.text = @"负".localized;
                self.resultLabel.textColor = kColorWith16RGB(0x333333);
            } else {
                self.resultLabel.text = @"胜".localized;
                self.resultLabel.textColor = kColorWith16RGB(0xe3170d);
            }
            self.blackPlayerNameLabel.text = game.blackPlayer.name;
            
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            f.dateFormat = @"YYYY-MM-dd";
            self.dateLabel.text = [f stringFromDate:game.playTime];
            
            [self.matchLabel sizeToFit];
            [self.redPlayerNameLabel sizeToFit];
            [self.blackPlayerNameLabel sizeToFit];
            [self.dateLabel sizeToFit];
            [self.resultLabel sizeToFit];
            
            self.matchLabel.hidden = NO;
            self.redPlayerNameLabel.hidden = NO;
            self.blackPlayerNameLabel.hidden = NO;
            self.dateLabel.hidden = NO;
            self.resultLabel.hidden = NO;
            self.titleLabel.hidden = YES;
        }
        
        
        [self relayout];
    }
}

- (void)setRecord:(CCPlayRecord *)record
{
    if (_record == record) return;
    
    _record = record;
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"YYYY-MM-dd HH:mm";
    self.dateLabel.text = [f stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.playTime]];
    [self.dateLabel sizeToFit];
    
    BOOL hasComment = record.comment.length > 0;
    
    if (hasComment) {
        self.titleLabel.text = record.comment;
    } else {
        
        switch (record.result) {
            case Tie:
                self.resultLabel.text = @"和".localized;
                self.resultLabel.textColor = kColorWith16RGB(0x999999);
                break;
            case Red:
                self.resultLabel.text = @"胜".localized;
                self.resultLabel.textColor = kColorWith16RGB(0xe3170d);
                break;
            case Black:
                self.resultLabel.text = @"负".localized;
                self.resultLabel.textColor = kColorWith16RGB(0x333333);
                break;
            case Unfinished:
                self.resultLabel.text = @"vs";
                self.resultLabel.textColor = kColorWith16RGB(0x999999);
                break;
        }
        self.resultLabel.font = LABEL_FONT(14.0);
        [self.resultLabel sizeToFit];
        
        switch (record.computerColor) {
            case CCEngineColor_None:
                self.redPlayerNameLabel.text = @"弈者".localized;
                self.blackPlayerNameLabel.text = @"弈者".localized;
                break;
            case CCEngineColor_Red:
                self.redPlayerNameLabel.text = @"电脑".localized;
                self.blackPlayerNameLabel.text = @"弈者".localized;
                break;
            case CCEngineColor_Black:
                self.redPlayerNameLabel.text = @"弈者".localized;
                self.blackPlayerNameLabel.text = @"电脑".localized;
                break;
        }
        [self.redPlayerNameLabel sizeToFit];
        [self.blackPlayerNameLabel sizeToFit];
    }
    self.titleLabel.hidden = !hasComment;
    self.resultLabel.hidden = hasComment;
    self.redPlayerNameLabel.hidden = hasComment;
    self.blackPlayerNameLabel.hidden = hasComment;
    
    [self relayout];
}

- (NSString *)title
{
    if (self.record.comment.length > 0) {
        return self.record.comment;
    }
    
    return [NSString stringWithFormat:@"%@  %@  %@", self.redPlayerNameLabel.text, self.resultLabel.text, self.blackPlayerNameLabel.text];
}
@end
