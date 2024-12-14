//
//  CCFullSearchViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/8/3.
//  Copyright © 2020 sheehangame. All rights reserved.
//

/**
 包含的搜索项：
 1、局面
 2、赛事名
 3、选手
 4、起止时间
 */

#import "CCFullSearchViewController.h"
#import "CCPhaseEditViewController.h"
#import "CCPhaseEditViewController.h"
#import "CCChessmanDataStructure.h"
#import "ChessDataModel.h"
#import "CCChesscore.h"
#import "CCGameSearchResultViewController.h"
#import "CCItemPickViewController.h"
#import "WSDatePickerView.h"
#import "CCButton.h"

#define PHASE_IMAGE_HEIGHT (200)

@interface CCFullSearchViewController () <UITableViewDelegate, UITableViewDataSource, CCPhaseEditViewControllerDelegate>

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *phaseImageView;
@property (nonatomic, strong) NSData *phasePresentation;

@property (nonatomic, strong) CCMatch *selectedMatch;
@property (nonatomic, strong) NSArray<CCMatch *> *allMatch;

@property (nonatomic, strong) CCPlayer *redPlayer;
@property (nonatomic, strong) CCPlayer *blackPlayer;
@property (nonatomic, strong) NSArray<CCPlayer *> *allPlayers;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, assign) BOOL ignore;

@end

@implementation CCFullSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"全面搜索".localized;
    
    self.phaseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PHASE_IMAGE_HEIGHT, PHASE_IMAGE_HEIGHT)];
    self.phaseImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    [self.view addSubview:self.tableView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"搜索".localized forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.rightButton = btn;
    self.rightButton.enabled = NO;

}

- (void)searchAction:(UIButton *)sender
{    
    CCGameSearchResultViewController *search = [[CCGameSearchResultViewController alloc] init];
    search.needPaging = YES;
    search.searchPhase = self.phasePresentation;
    search.searchMatchID = self.selectedMatch.matchID;
    search.searchRedPlayerID = self.redPlayer.playerID;
    search.searchBlackPlayerID = self.blackPlayer.playerID;
    search.ignore = self.ignore;
    search.startTime = self.startDate ? [self.startDate timeIntervalSince1970] : NSNotFound;
    search.endTIme = self.endDate ? [self.endDate timeIntervalSince1970] : NSNotFound;
    
    [self.navigationController pushViewController:search animated:YES];
}

- (void)updateSearchButton
{
    if (!self.phasePresentation && !self.redPlayer && !self.selectedMatch && !self.blackPlayer && !self.startDate && !self.endDate) {
        self.rightButton.enabled = NO;
    } else {
        self.rightButton.enabled = YES;
    }
}

- (CCButton *)clearButtonWith:(NSIndexPath *)indexPath
{
    CCButton *btn = [CCButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [btn sizeToFit];
    return btn;
}

- (void)switchValueChanged:(UISwitch *)sw
{
    self.ignore = sw.isOn;
}

- (void)clearButtonAction:(CCButton *)sender
{
    switch (sender.indexPath.section) {
        case 0:
            self.phaseImageView.image = nil;
            self.phasePresentation = nil;
            break;
        case 1:
            self.selectedMatch = nil;
            break;
        case 2:
            if (sender.indexPath.row == 0) {
                self.redPlayer = nil;
            } else if (sender.indexPath.row == 1) {
                self.blackPlayer = nil;
            }
            break;
        case 3:
            if (sender.indexPath.row == 0) {
                self.startDate = nil;
            } else if (sender.indexPath.row == 1) {
                self.endDate = nil;
            }
            break;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateSearchButton];
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return PHASE_IMAGE_HEIGHT;
    }
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cnt = 0;
    switch (section) {
        case 0:
            cnt = 1;
            break;
        case 1:
            cnt = 1;
            break;
        case 2:
            cnt = 3;
            break;
        case 3:
            cnt = 2;
            break;
    }
    
    return cnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0 && self.phaseImageView.superview != cell.contentView) {
        [cell.contentView addSubview:self.phaseImageView];
        
        self.phaseImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.phaseImageView.widthAnchor constraintEqualToConstant:PHASE_IMAGE_HEIGHT] setActive:YES];
        [[self.phaseImageView.heightAnchor constraintEqualToConstant:PHASE_IMAGE_HEIGHT] setActive:YES];
        [[self.phaseImageView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor] setActive:YES];
        [[self.phaseImageView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor] setActive:YES];
    }
    
    BOOL needAccessoryView = NO;
    BOOL needSwitch = NO;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"局面".localized;
            cell.detailTextLabel.text = nil;
            needAccessoryView = self.phasePresentation.length > 0;
            break;
        case 1:
            cell.textLabel.text = @"赛事".localized;
            cell.detailTextLabel.text = self.selectedMatch.name;
            needAccessoryView = !!self.selectedMatch;
            break;
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"红方".localized;
                cell.detailTextLabel.text = self.redPlayer.name;
                needAccessoryView = !!self.redPlayer;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"黑方".localized;
                cell.detailTextLabel.text = self.blackPlayer.name;
                needAccessoryView = !!self.blackPlayer;
            } else {
                cell.textLabel.text = @"任意先手".localized;
                cell.detailTextLabel.text = nil;
                needAccessoryView = YES;
                needSwitch = YES;
            }
            break;
        case 3:
        {
            NSDateFormatter *f = [NSDateFormatter new];
            [f setDateFormat:@"YYYY-MM-dd"];
            if (indexPath.row == 0) {
                cell.textLabel.text = @"起始时间".localized;
                if (self.startDate) {
                    cell.detailTextLabel.text = [f stringFromDate:self.startDate];
                } else {
                    cell.detailTextLabel.text = nil;
                }
                needAccessoryView = !!self.startDate;
            } else {
                cell.textLabel.text = @"截止时间".localized;
                if (self.endDate) {
                    cell.detailTextLabel.text = [f stringFromDate:self.endDate];
                } else {
                    cell.detailTextLabel.text = nil;
                }
                needAccessoryView = !!self.endDate;
            }
        }
            break;
    }
    
    CCButton *btn = (CCButton *)cell.accessoryView;
    if (needAccessoryView) {
        if (needSwitch) {
            UISwitch *sw = nil;
            if ([btn isKindOfClass:[UISwitch class]]) {
                sw = (UISwitch *)btn;
            } else {
                sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            }
            [sw setOn:self.ignore];
            cell.accessoryView = sw;
        } else {
            if (!btn || ![btn isKindOfClass:[CCButton class]]) {
                btn = [self clearButtonWith:indexPath];
                cell.accessoryView = btn;
            }
            btn.indexPath = indexPath;
        }
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTips = nil;
    switch (section) {
        case 0:

            break;
        case 1:

            break;
        case 2:
            headerTips = @"搜索指定选手的对局".localized;
            break;
        case 3:
            headerTips = @"搜索时间段内的对局".localized;
            break;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *tips = nil;
    switch (section) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            tips = @"红方、黑方选择相同选手时可以查找该选手的所有对局。\n打开”任意先手“开关可以查找双方全部对局。".localized;
            break;
        case 3:
            tips = @"起止时间可以只填写其中一个".localized;
            break;
    }
    
    return tips;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            CCPhaseEditViewController *evc = [[CCPhaseEditViewController alloc] initWithInitialPhase:self.phasePresentation];
            evc.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:evc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:nav animated:YES completion:^{
                [[KKAdHelper sharedInstance] bringBannerView];
            }];
        }
            break;
        case 1:
        {
            // match
            if (self.allMatch.count == 0) {
                self.allMatch = [[CCChesscore core] allMatch];
            }
            
            NSInteger section = indexPath.section;
            CCItemPickViewController *picker = [[CCItemPickViewController alloc] initWithItems:[self.allMatch valueForKey:@"name"] specialItems:nil specialTitle:nil];
            picker.title = @"赛事选择".localized;
            picker.doneAction = ^(NSInteger selectedIndex) {
                self.selectedMatch = self.allMatch[selectedIndex];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                [self updateSearchButton];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:^{
                [[KKAdHelper sharedInstance] bringBannerView];
            }];
        }
            break;
        case 2:
        {
            if (indexPath.row == 2) {
                return;
            }
            
            if (self.allPlayers.count == 0) {
                self.allPlayers = [[[CCChesscore core] allPlayers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name != %@", @"__noname__"]];
            }
            
            NSInteger section = indexPath.section;
            NSInteger row = indexPath.row;
            NSArray *history = [[CCChesscore core] playerAccessHistory];
            CCItemPickViewController *picker = [[CCItemPickViewController alloc] initWithItems:[self.allPlayers valueForKey:@"name"] specialItems:[history valueForKey:@"name"] specialTitle:@"历史记录".localized];
            picker.title = @"棋手选择".localized;
            picker.doneAction = ^(NSInteger selectedIndex) {
                if (row == 0) {
                    // red player
                    self.redPlayer = self.allPlayers[selectedIndex];
                } else {
                    // black player
                    self.blackPlayer = self.allPlayers[selectedIndex];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                [self updateSearchButton];
            };
            picker.specialDoneAction = ^(NSInteger selectedIndex) {
                if (row == 0) {
                    // red player
                    self.redPlayer = history[selectedIndex];
                } else {
                    // black player
                    self.blackPlayer = history[selectedIndex];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                [self updateSearchButton];
            };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:^{
                [[KKAdHelper sharedInstance] bringBannerView];
            }];
        }
            break;
        case 3:
        {
            WSDatePickerView *datePicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay CompleteBlock:^(NSDate *date) {
                if (!date) return;
                
                if (indexPath.row == 0) {
                    self.startDate = date;
                } else {
                    self.endDate = date;
                }
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self updateSearchButton];
            }];
            
            if (indexPath.row == 0 && self.endDate) {
                // 如果设置过截止时间，那挑选起始时间时不得超过endDate
                NSTimeInterval max = [self.endDate timeIntervalSince1970] - 24 * 3600;
                datePicker.maxLimitDate = [NSDate dateWithTimeIntervalSince1970:max];
            } else if (indexPath.row == 1 && self.startDate) {
                // end time. 同理
                NSTimeInterval min = [self.startDate timeIntervalSince1970] + 24 * 3600;
                datePicker.minLimitDate = [NSDate dateWithTimeIntervalSince1970:min];
            }
            
            [datePicker show];
        }
            break;
    }
}

#pragma mark - CCPhaseEditViewControllerDelegate
- (void)phaseEditViewController:(CCPhaseEditViewController *)viewController didFinished:(UIImage *)boardImage phase:(NSData *)phase
{
    self.phasePresentation = phase;
    if (self.phasePresentation.length > 0) {
        self.phaseImageView.image = boardImage;
    } else {
        self.phaseImageView.image = nil;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self updateSearchButton];
    
    [viewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
