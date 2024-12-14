//
//  GameViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "GameViewController.h"
#import "CCPhaseEditViewController.h"
#import "CCGameWatchViewController.h"
#import "UIView+CCFast.h"
#import <SSZipArchive/SSZipArchive.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "CCFullSearchViewController.h"
#import "CCChesscore.h"
#import "KKAdHelper.h"
#import "CCOldBookViewController.h"
#import "CCItemPickViewController.h"
#import "CCPlayerDataViewController.h"
#import "CCSettingsViewController.h"
#import "UIImage+CCUtil.h"
#import "CCPlayViewController.h"
#import "GULReachabilityChecker.h"
#import "KKStoreKitHelper.h"
#import "CCEngineSettingViewController.h"
#import "EngineWrapper.h"
#import "CCPlayRecordsViewController.h"

#define BUTTON_HEIGHT (60)
#define BUTTON_SPACING (30)
#define BUTTON_WIDTH (150)

#define BANNER_AD_ID @"ca-app-pub-3940256099942544/2934735716"

@interface GameViewController () <GULReachabilityDelegate>

@property (nonatomic, strong) UIStackView *menu;
@property (nonatomic, strong) NSArray<CCPlayer *> *allPlayer;

@property (nonatomic, assign) BOOL didCheckDB;

@property (nonatomic, assign) int remindTimes;

@property (nonatomic, strong) GULReachabilityChecker *checker;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![KKStoreKitHelper sharedInstance].adRemoved) {
        if (@available(iOS 15.0, *)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[KKAdHelper sharedInstance] loadBannerAd:BANNER_AD_ID rootViewController:self.navigationController];
            });
        } else {
            [[KKAdHelper sharedInstance] loadBannerAd:BANNER_AD_ID rootViewController:self.navigationController];
        }
    }
    
    self.title = @"象棋助手".localized;
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    UIButton *phaseSearch = [self buttonWithTitle:@"局面检索".localized action:@selector(phaseSearchButtonAction:)];
    UIButton *fullSearch = [self buttonWithTitle:@"全面检索".localized action:@selector(fullSearchButtonAction:)];
    UIButton *oldBook = [self buttonWithTitle:@"古谱学习".localized action:@selector(oldBookLearnButtonAction:)];
    UIButton *searchInfo = [self buttonWithTitle:@"棋手数据".localized action:@selector(searchPlayerInfo:)];
    UIButton *play = [self buttonWithTitle:@"对 弈".localized action:@selector(playWithComputerButtonAction:)];
    
    self.menu = [[UIStackView alloc] initWithArrangedSubviews:@[phaseSearch, fullSearch, oldBook, searchInfo, play]];
    self.menu.axis = UILayoutConstraintAxisVertical;
    self.menu.distribution = UIStackViewDistributionEqualSpacing;
    self.menu.alignment = UIStackViewAlignmentFill;
    [self.view addSubview:self.menu];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self setRightButton:@"设置".localized image:nil target:self action:@selector(leftButtonAction:)];
    
    self.remindTimes = 0;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [EngineWrapper shared];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.didCheckDB) {
        self.didCheckDB = YES;
        
        NSString *dbPath = DB_PATH;
        DLog(@"dbpath: %@", dbPath);
        
        BOOL isDir = NO;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dbPath isDirectory:&isDir];
        if (!exist || isDir) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"数据解压中".localized;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *zipFilePath = [[NSBundle mainBundle] pathForResource:@"chinese_chess" ofType:@"zip"];
                
                TICK(unzip)
                
                NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                for (NSString *file in [[NSFileManager defaultManager] subpathsAtPath:documentDir]) {
                    if ([file hasSuffix:@"sqlite"] && ![file containsString:@"games.sqlite"]) {
                        [[NSFileManager defaultManager] removeItemAtPath:[documentDir stringByAppendingPathComponent:file] error:NULL];
                    }
                }
                
                NSError *error = nil;
                [SSZipArchive unzipFileAtPath:zipFilePath toDestination:documentDir overwrite:YES password:nil error:&error];
                
                if (error) {
                    DLog(@"failed to unzip with error: %@", error);
                }
                
                TOCK(unzip)
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
            
            return;
        }
    }
    if (self.remindTimes < 3) {
        [self checkNetworkReachbility];
    }
}

- (void)checkNetworkReachbility
{
    if (!self.checker) {
        self.checker = [[GULReachabilityChecker alloc] initWithReachabilityDelegate:self withHost:@"www.apple.com"];
        [self.checker start];
    } else {
        if (self.checker.reachabilityStatus == kGULReachabilityUnknown || self.checker.reachabilityStatus == kGULReachabilityNotReachable) {
            [self showNetworkAlert];
        }
    }
}

- (void)reachability:(GULReachabilityChecker *)reachability statusChanged:(GULReachabilityStatus)status
{
    if (status == kGULReachabilityUnknown || status == kGULReachabilityNotReachable) {
        [self showNetworkAlert];
    }
}

- (void)showNetworkAlert
{
    if (self.remindTimes >= 3) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无网络连接".localized message:@"本应用依赖广告收入来维持，无网络将无法展示广告，感谢理解！".localized preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url != nil) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    
    [self presentViewController:alert animated:true completion:NULL];
    
    self.remindTimes += 1;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.menu.frame = CGRectMake(0, self.view.safeAreaInsets.top, BUTTON_WIDTH, self.menu.arrangedSubviews.count * (BUTTON_HEIGHT + BUTTON_SPACING) - BUTTON_SPACING);
    self.menu.center = self.view.center;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = LABEL_FONT(20);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button setBackgroundImage:[UIImage imageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] size:CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT)] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    
    return button;
}

- (void)phaseSearchButtonAction:(UIButton *)sender
{
    [self.navigationController pushViewController:[CCPhaseEditViewController new] animated:YES];
}

- (void)fullSearchButtonAction:(UIButton *)sender
{
    [self.navigationController pushViewController:[CCFullSearchViewController new] animated:YES];
}

- (void)oldBookLearnButtonAction:(UIButton *)sender
{
    [self.navigationController pushViewController:[CCOldBookViewController new] animated:YES];
}

- (void)searchPlayerInfo:(UIButton *)sender
{
    if (!self.allPlayer) {
        self.allPlayer = [[[CCChesscore core] allPlayers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name != %@", @"__noname__"]];
    }
    
    NSArray *history = [[CCChesscore core] playerAccessHistory];
    CCItemPickViewController *ipvc = [[CCItemPickViewController alloc] initWithItems:[self.allPlayer valueForKey:@"name"] specialItems:[history valueForKey:@"name"] specialTitle:@"历史记录".localized];
    ipvc.title = @"棋手选择".localized;
    ipvc.doneAction = ^(NSInteger selectedIndex) {
        CCPlayer *sp = [self.allPlayer objectAtIndex:selectedIndex];
        
        CCPlayerDataViewController *vc = [[CCPlayerDataViewController alloc] initWithNibName:nil bundle:nil];
        vc.queryPlayer = sp;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        [[CCChesscore core] increaseAccessTime:sp.playerID];
    };
    
    ipvc.specialDoneAction = ^(NSInteger selectedIndex) {
        CCPlayer *sp = [history objectAtIndex:selectedIndex];
        
        CCPlayerDataViewController *vc = [[CCPlayerDataViewController alloc] initWithNibName:nil bundle:nil];
        vc.queryPlayer = sp;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        [[CCChesscore core] increaseAccessTime:sp.playerID];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ipvc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:^{
        [[KKAdHelper sharedInstance] bringBannerView];
    }];
}

- (void)playWithComputerButtonAction:(UIButton *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"对弈模式".localized message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    weakify(self)
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"人机对战".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weak_self dealPlaySelected:NO];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"左右互搏".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weak_self dealPlaySelected:YES];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"我的对局".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CCPlayRecordsViewController *vc = [CCPlayRecordsViewController new];
        vc.title = @"我的对局".localized;
        [self.navigationController pushViewController:vc animated:true];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentVC:actionSheet from:sender];
}

- (void)dealPlaySelected:(BOOL)selfPlay
{
    CCPlayUnfinishedModel *model = [[CCChesscore core] lastPlayModel:selfPlay];
    if (!model || model.setting == nil || model.moveList.length <= 0) {
        [self showEngineSetting:selfPlay];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示".localized message:@"检测到上次有未完成对局，是否继续？".localized preferredStyle:UIAlertControllerStyleAlert];
    weakify(self)
    [alert addAction:[UIAlertAction actionWithTitle:@"继续".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CCPlayViewController *pvc = [[CCPlayViewController alloc] initWithEngine:model.setting moveList:model.moveList];
        
        pvc.title = selfPlay ? @"左右互搏".localized : @"人机对战".localized;
        [weak_self.navigationController pushViewController:pvc animated:true];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"新对局".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weak_self showEngineSetting:selfPlay];
    }]];
    
    [self presentViewController:alert animated:true completion:NULL];
}

- (void)showEngineSetting:(BOOL)selfPlay
{
    CCEngineSettingViewController* svc = [[CCEngineSettingViewController alloc] initWithPlayMode:selfPlay];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:svc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    weakify(self)
    svc.completion = ^(CCEngineSetting * _Nullable setting) {
        if (!setting || !weak_self || !setting) return;
        
        [weak_self.navigationController dismissViewControllerAnimated:false completion:NULL];
        CCPlayViewController *pvc = [[CCPlayViewController alloc] initWithEngine:setting moveList:nil];
        pvc.title = selfPlay ? @"左右互搏".localized : @"人机对战".localized;
        [weak_self.navigationController pushViewController:pvc animated:true];
    };
    [self.navigationController presentViewController:nav animated:true completion:NULL];
}

- (void)leftButtonAction:(UIButton *)sender
{
    CCSettingsViewController *svc = [[CCSettingsViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
