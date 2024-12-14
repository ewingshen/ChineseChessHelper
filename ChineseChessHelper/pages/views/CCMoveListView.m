//
//  CCMoveListView.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/6.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCMoveListView.h"
#import "CCChessUtil.h"
#import "CCMoveListCell.h"

static NSString *cellIndetifier = @"list_view_cell_identifier";

@interface CCMoveListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, assign) int currentIndex;

@end

@implementation CCMoveListView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIndex = 0;
        
        self.listView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self.listView registerClass:[CCMoveListCell class] forCellReuseIdentifier:cellIndetifier];
        self.listView.delegate = self;
        self.listView.dataSource = self;
        [self addSubview:self.listView];
    }
    
    return self;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        [self.listView reloadData];
    }
}

- (void)updateSelectedIndex:(int)ci
{
    if (ci != self.currentIndex) {
        self.currentIndex = ci;
        [self.listView reloadData];
        
        [self.listView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ci inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.listView.frame = self.bounds;
}
#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.translatedMoves.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCMoveListCell *cell = (CCMoveListCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (!cell) {
        cell = [[CCMoveListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndetifier];
    }
    
    if (indexPath.row == 0) {
        [cell updateTitle:@" " move:@"开局".localized];
    } else {
        int index = (int)indexPath.row - 1;
        [cell updateTitle:(index % 2 == 0 ? [NSString stringWithFormat:@"%d", index / 2 + 1] : @"") move:self.translatedMoves[index]];
    }
    
    if (self.currentIndex == indexPath.row) {
        [cell updateTextColor:kColorWith16RGB(0x00bfff)];
    } else {
        [cell updateTextColor:UIColor.blackColor];
    }
    [cell setSelected:self.currentIndex == indexPath.row animated:false];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.moveSelectAction) {
        self.moveSelectAction((int)indexPath.row);
    }
    
    self.currentIndex = (int)indexPath.row;
    [tableView reloadData];
}
@end
