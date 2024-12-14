//
//  CCPlayRecordsViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/3.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCPlayRecordsViewController.h"
#import "CCChessCore.h"
#import "CCGameTableViewCell.h"
#import "UIView+CCFast.h"
#import "CCGameWatchViewController.h"
#import "NSArray+Utils.h"

@interface CCPlayRecordsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) NSMutableArray<CCPlayRecord *> *data;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) int pageSize;
@end

@implementation CCPlayRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    self.page = 0;
    self.pageSize = 100;
    // Do any additional setup after loading the view.
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.view.width, 80)];
    self.statusLabel.text = @"- 无对局 -".localized;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textColor = kColorWith16RGB(0x999999);
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.statusLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[CCGameTableViewCell class] forCellReuseIdentifier:CCGameTableViewCell.cc_reuseIdentifier];
    [self.view addSubview:self.tableView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    
    [self loadData];
    
    [self.tableView reloadData];
}

- (void)loadData
{
    if (self.page < 0) return;
    weakify(self)
    [[CCChesscore core] loadRecordAt:self.page pageSize:self.pageSize completion:^(NSArray<CCPlayRecord *> * _Nonnull records) {
        if (!weak_self) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (records.count < weak_self.pageSize) {
                weak_self.page = -1;
            } else {
                weak_self.page += 1;
            }
            
            [weak_self.data addObjectsFromArray: records];
            DLog("now data count: %d", (int)weak_self.data.count);
            [weak_self.tableView reloadData];
            weak_self.statusLabel.hidden = weak_self.data.count > 0;
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCGameTableViewCell.cc_reuseIdentifier forIndexPath:indexPath];
    
    CCPlayRecord *record = self.data[indexPath.row];
    if (record != nil) {
        cell.record = record;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCPlayRecord *record = self.data[indexPath.row];
    if (record) {
        CCGameTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CCGameWatchViewController *wvc = [[CCGameWatchViewController alloc] initWithRecord:record];
        wvc.title = [cell title];
        [self.navigationController pushViewController:wvc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.data.count - 1) {
        [self loadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除".localized;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CCPlayRecord *r = self.data[indexPath.row];
        if (r != nil) {
            [[CCChesscore core] removeRecord:r.recordID];
            [self.data removeObject:r];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.statusLabel.hidden = self.data.count > 0;
        }
    }
}
@end
