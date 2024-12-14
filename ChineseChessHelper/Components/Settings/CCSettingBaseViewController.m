//
//  CCSettingBaseViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/11/27.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCSettingBaseViewController.h"
#import "CCSettingItemTableViewCell.h"
#import "UIView+CCFast.h"

@interface CCSettingBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<CCSettingItem *> *data;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CCSettingBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.data = [NSMutableArray array];
    
    UITableView *tb = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tb.delegate = self;
    tb.dataSource = self;
    tb.backgroundColor = [UIColor clearColor];
    tb.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    [self.view addSubview:tb];
    self.tableView = tb;
    
    [self setupData];
    [self.tableView reloadData];
}

- (void)setupData 
{
    
}

- (void)update 
{
    [self setupData];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCSettingItem *item = self.data[indexPath.row];
    
    if (item.height > 0) {
        return item.height;
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCSettingItem *item = self.data[indexPath.row];
    
    CCSettingItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CCSettingItemTableViewCell cc_reuseIdentifier]];
    if (!cell) {
        cell = [[CCSettingItemTableViewCell alloc] initWithStyle:item.style reuseIdentifier:[CCSettingItemTableViewCell cc_reuseIdentifier]];
    }
    
    [cell bind:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCSettingItem *item = self.data[indexPath.row];
    
    CALL_BLOCK(item.selectedAction)
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
}

@end
