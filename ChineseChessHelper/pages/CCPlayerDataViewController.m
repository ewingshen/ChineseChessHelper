//
//  CCPlayerDataViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/9/3.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCPlayerDataViewController.h"
#import "CCChesscore.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CCGameTableViewCell.h"
#import "CCGameWatchViewController.h"
#import "CCGameSearchResultViewController.h"
#import "CCGameStatisticsTableViewCell.h"
#import "UIView+CCFast.h"
#import "CCOpponentTableViewCell.h"

@interface CCPlayerDataViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) CCPlayerData *playerData;

@end

@implementation CCPlayerDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.queryPlayer.name;
    
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.table registerClass:[CCGameTableViewCell class] forCellReuseIdentifier:CCGameTableViewCell.cc_reuseIdentifier];
    [self.table registerClass:[CCGameStatisticsTableViewCell class] forCellReuseIdentifier:CCGameStatisticsTableViewCell.cc_reuseIdentifier];
    [self.table registerClass:[CCOpponentTableViewCell class] forCellReuseIdentifier:CCOpponentTableViewCell.cc_reuseIdentifier];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    self.table.backgroundColor = [UIColor clearColor];
    self.table.tableFooterView = [UIView new];
    self.table.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.table];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.playerData) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].label.text = @"数据统计中...".localized;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.playerData = [[CCChesscore core] queryPlayerInfoOf:self.queryPlayer];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
}

#pragma · UITableViewDelegate And UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.playerData) {
        return 3;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.playerData.opponents.count;
    } else if (section == 2) {
        return self.playerData.allGames.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 300;
            break;
        case 1:
            return 54;
        case 2:
            return 80;
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"对局统计".localized;
    } else if (section == 1) {
        return @"对手统计".localized;
    } else if (section == 2) {
        return @"所有比赛".localized;
    }
    
    return nil;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return @[@"计".localized, @"敌".localized, @"局".localized];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section) {
        case 0:
        {
            CCGameStatisticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCGameStatisticsTableViewCell.cc_reuseIdentifier forIndexPath:indexPath];
            weakify(self)
            cell.selectedYear = ^(NSInteger year) {
                if (!weak_self) return;
                
                CCPlayerYearData *data = [weak_self.playerData.yearData first:^BOOL(CCPlayerYearData * _Nonnull item) {
                    return item.year == year;
                }];
                
                if (data.games.count <= 0) return;
                
                CCGameSearchResultViewController *vc = [[CCGameSearchResultViewController alloc] initWithNibName:nil bundle:nil];
                vc.search = NO;
                vc.game2Display = data.games;
                vc.title = [NSString stringWithFormat:@"%@(%04ld)", weak_self.queryPlayer.name, data.year];
                [weak_self.navigationController pushViewController:vc animated:YES];
            };
            [cell update:self.playerData];
            return cell;
        }
            break;
        case 1:
        {
            CCOpponentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCOpponentTableViewCell.cc_reuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < self.playerData.opponents.count) {
                [cell update:self.playerData.opponents[indexPath.row]];
            }
            
            return cell;
        }
            break;
        default:
        {
            CCGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCGameTableViewCell.cc_reuseIdentifier forIndexPath:indexPath];
            
            CCGame *game = self.playerData.allGames[indexPath.row];
            
            cell.game = game;
            
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        CCPlayer *player = self.playerData.opponents[indexPath.row].player;
        NSArray<CCGame *> *games = [self.playerData.allGames filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CCGame *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (evaluatedObject && (evaluatedObject.redPlayer.playerID == player.playerID || evaluatedObject.blackPlayer.playerID == player.playerID)) {
                return YES;
            }
            return NO;
        }]];
        
        CCGameSearchResultViewController *vc = [[CCGameSearchResultViewController alloc] initWithNibName:nil bundle:nil];
        vc.search = NO;
        vc.game2Display = games;
        vc.title = [NSString stringWithFormat:@"%@ vs %@", self.queryPlayer.name, player.name];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 2) {
        CCGame *g = self.playerData.allGames[indexPath.row];
        
        CCGameWatchViewController *wvc = [[CCGameWatchViewController alloc] initWithGame:g];
        [self.navigationController pushViewController:wvc animated:YES];
    }
}
@end
