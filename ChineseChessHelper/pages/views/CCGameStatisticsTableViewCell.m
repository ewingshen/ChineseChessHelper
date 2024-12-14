//
//  CCGameStatisticsTableViewCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/4/17.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCGameStatisticsTableViewCell.h"
#import "ChessDataModel.h"
#import "UIView+CCFast.h"
#import "CCGameCountView.h"
#import "CCChartView.h"
#import "CC2DEntry.h"

@interface CCGameStatisticsTableViewCell ()

@property(nonatomic, strong) CCGameCountView *total;
@property(nonatomic, strong) CCGameCountView *red;
@property(nonatomic, strong) CCGameCountView *black;

@property(nonatomic, strong) CCChartView *winRateView;

@end

@implementation CCGameStatisticsTableViewCell

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
    self.total = [[CCGameCountView alloc] initWithFrame:CGRectZero title:@"总计".localized];
    [self.contentView addSubview:self.total];
    
    self.red = [[CCGameCountView alloc] initWithFrame:CGRectZero title:@"执红".localized];
    [self.contentView addSubview:self.red];
    
    self.black = [[CCGameCountView alloc] initWithFrame:CGRectZero title:@"执黑".localized];
    [self.contentView addSubview:self.black];
    

    self.winRateView = [[CCChartView alloc] initWithFrame:CGRectZero];
    self.winRateView.titile = @"历年胜率".localized;
    weakify(self)
    self.winRateView.selecteEntry = ^(CC2DEntry * _Nonnull entry) {
        CALL_BLOCK(weak_self.selectedYear, [entry.x integerValue])
    };
    [self.contentView addSubview:self.winRateView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.width - 32;
    CGFloat height = 30.0f;
    CGFloat vspacing = 10.0f;
    self.total.frame = CGRectMake(16, 10, width, height);
    self.red.frame = CGRectMake(16, self.total.bottom + vspacing, width, height);
    self.black.frame = CGRectMake(16, self.red.bottom + vspacing, width, height);
    
    self.winRateView.frame = CGRectMake(16, self.black.bottom + vspacing * 2, width, 150);
}

- (void)update:(CCPlayerData *)data
{
    int totalCnt = data.redCount + data.blackCount;
    int winCnt = data.redWinCount + data.blackWinCount;
    int tieCnt = data.redTieCount + data.blackTieCount;
    int loseCnt = totalCnt - winCnt - tieCnt;
    [self.total updateWin:winCnt tie:tieCnt lose:loseCnt];
    
    [self.red updateWin:data.redWinCount tie:data.redTieCount lose:data.redCount - data.redWinCount - data.redTieCount];
    [self.black updateWin:data.blackWinCount tie:data.blackTieCount lose:data.blackCount - data.blackWinCount - data.blackTieCount];
    
    NSMutableArray<CC2DEntry *> *entries = [NSMutableArray array];
    for (CCPlayerYearData *year in data.yearData) {
        if (year.year == 1970) continue;
        CC2DEntry *entry = [CC2DEntry new];
        entry.x = [NSString stringWithFormat:@"%04ld", year.year];
        entry.y = [NSString stringWithFormat:@"%d%%", (int)(year.winRate * 100)];
        entry.height = year.winRate;
        
        [entries addObject:entry];
    }
    self.winRateView.entries = entries;
}
@end
