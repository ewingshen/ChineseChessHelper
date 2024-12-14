//
//  CCGameSearchResultViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/27.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCGameSearchResultViewController.h"
#import "CCChesscore.h"
#import "CCGameWatchViewController.h"
#import "CCGameTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+CCFast.h"

static NSString *cellIdentifier = @"game_cell_identifier";

#define CELL_HEIGHT (80)
#define SEARCH_PAGE_SIZE (20)

@interface CCGameSearchResultViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<CCGame *> *games;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *timeSortButton;

@end

@implementation CCGameSearchResultViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.startTime = NSNotFound;
        self.endTIme = NSNotFound;
        self.search = YES;
    }
    return self;
}

- (void)dealloc
{
    [[CCChesscore core] stopQuery];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.title) {
        [self setTitle:@"搜索".localized];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.search) {
        self.timeSortButton = [self setRightButton:@"正序".localized image:nil target:self action:@selector(timeSortButtonAction)];
        [self.timeSortButton setTitle:@"逆序".localized forState:UIControlStateSelected];
        
        self.games = [NSMutableArray arrayWithCapacity:20];
    }
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CELL_HEIGHT)];
    self.statusLabel.text = self.search ? @"检索中...".localized : @"- 暂无更多 -".localized;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textColor = kColorWith16RGB(0x999999);
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.contentMode = UIViewContentModeCenter;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = self.statusLabel ?: [UIView new];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[CCGameTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.games.count == 0 && self.search) {
        [self searchGameAtPage:0];
    }
}

- (void)searchGameAtPage:(NSInteger)page
{
    if (self.isSearching) return;
    self.isSearching = YES;
    
    __weak typeof(self) weakSelf = self;
    BOOL timeOrderDESC = self.timeSortButton.selected;
    self.statusLabel.text = @"检索中...";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (weakSelf) {
            NSArray *gs = [[CCChesscore core] queryGameWithPhase:weakSelf.searchPhase
                                                       redPlayer:weakSelf.searchRedPlayerID
                                                     blackPlayer:weakSelf.searchBlackPlayerID
                                                      ignoreSide:weakSelf.ignore
                                                           match:weakSelf.searchMatchID
                                                       startTime:weakSelf.startTime
                                                         endTime:weakSelf.endTIme
                                                       pageIndex:(int)page
                                                        pageSize:(weakSelf.needPaging ? SEARCH_PAGE_SIZE : 0)
                                                        sortType:(weakSelf.sortByTitle ? CCChessGameSortType_Title : CCChessGameSortType_Date)
                                                         sortAsc:timeOrderDESC];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    if (timeOrderDESC != weakSelf.timeSortButton.selected) {
                        return;
                    }
                    
                    if (gs.count > 0) {
                        [weakSelf.games addObjectsFromArray:gs];
                        [weakSelf.tableView reloadData];
                    }
                    
                    if (gs.count == SEARCH_PAGE_SIZE) {
                        weakSelf.statusLabel.text = @"检索中...".localized;
                    } else if (weakSelf.games.count > 0) {
                        weakSelf.statusLabel.text = @"- 暂无更多 -".localized;
                    } else {
                        weakSelf.statusLabel.text = @"- 无对局 -".localized;
                    }
                    
                    weakSelf.isSearching = NO;
                }
            });
        }
    });
}

- (void)timeSortButtonAction
{
    self.timeSortButton.selected = !self.timeSortButton.selected;
    
    [self.games removeAllObjects];
    [self.tableView reloadData];
    [[CCChesscore core] stopQuery];
    self.isSearching = NO;
    [self searchGameAtPage:0];
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.search) {
        return self.games.count;
    } else {
        return self.game2Display.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.search) {
        cell.game = self.games[indexPath.row];
    } else {
        cell.game = self.game2Display[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CCGameWatchViewController *wvc = [[CCGameWatchViewController alloc] initWithGame: self.search ? self.games[indexPath.row] : self.game2Display[indexPath.row]];
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.search) {
        if (indexPath.row == MAX(self.games.count - SEARCH_PAGE_SIZE * 0.7, self.games.count * 0.7) && self.games.count % SEARCH_PAGE_SIZE == 0) {
            [self searchGameAtPage:self.games.count / SEARCH_PAGE_SIZE];
        }
    }
}

@end
