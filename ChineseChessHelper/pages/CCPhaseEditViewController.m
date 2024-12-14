//
//  CCPhaseEditViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/2.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCPhaseEditViewController.h"
#import "CCChessBoard.h"
#import "UIView+CCFast.h"
#import "CCChessUtil.h"
#import "CCToolbar.h"
#import "CCGameSearchResultViewController.h"
#import <Toast.h>

#define MENU_HEIGHT (50)
#define LIST_VIEW_WIDTH (100)

@interface CCPhaseEditViewController () <CCToolbarDelegate>

@property (nonatomic, strong) CCChessBoard *board;
@property (nonatomic, strong) CCToolbar *menu;

@property (nonatomic, strong) NSData *initialPhase;

@end

@implementation CCPhaseEditViewController

- (instancetype)initWithInitialPhase:(NSData *)ip
{
    self = [super init];
    if (self) {
        self.initialPhase = ip;
    }
    return self;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = LABEL_FONT(18);
    
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"局面编辑".localized;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *rightTitle = @"搜索".localized;
    if (self.delegate) {
        rightTitle = @"完成".localized;
    }
    
    [self setRightButton:rightTitle image:nil target:self action:@selector(doneAction:)];
    
    self.menu = [[CCToolbar alloc] initWithFrame:CGRectZero buttonTitles:@[@"开局".localized, @"重置".localized, @"回退".localized] delegate:self];
    [self.view addSubview:self.menu];
    
    self.board = [[CCChessBoard alloc] initWithFrame:CGRectZero];
    self.board.initialPhase = self.initialPhase;
    self.board.mode = CCChessboardMode_Edit;
    if (self.board.initialPhase.length > 0) {
        [self.board resetChessman2Ready];
    }
    __weak typeof(self) weakSelf = self;
    self.board.frameChangeAction = ^{
        if (weakSelf) {
            weakSelf.board.center = CGPointMake(weakSelf.view.width * 0.5, weakSelf.view.safeAreaInsets.top + weakSelf.board.height * 0.5);
            weakSelf.menu.frame = CGRectMake(0, weakSelf.board.bottom, weakSelf.view.width, MENU_HEIGHT);
        }
    };
    
    [self.view addSubview:self.board];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.board.width == 0) {
        self.board.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top, self.view.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - MENU_HEIGHT - AD_HEIGHT);
    }
    self.menu.frame = CGRectMake(0, self.board.bottom, self.view.width, MENU_HEIGHT);
}

#pragma mark -
- (void)doneAction:(UIButton *)sender
{
    NSString *msg = [self.board phaseCheckValid];
    
    if (msg.length > 0) {
        [self.view makeToast:msg duration:1.5 position:CSToastPositionCenter];
        return;
    }
    
    NSData *p = [self.board genPhasePresentation];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(phaseEditViewController:didFinished:phase:)]) {
        [self.delegate phaseEditViewController:self didFinished:[self.board boardImage] phase:p];
    } else {
        CCGameSearchResultViewController *vc = [[CCGameSearchResultViewController alloc] initWithNibName:nil bundle:nil];
        vc.needPaging = YES;
        vc.searchPhase = p;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - CCToolBar Delegate
- (void)toolbar:(CCToolbar *)tb clickButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            [self.board resetChessman2Ready];
            break;
        case 1:
            [self.board clearAll];
            break;
        case 2:
            [self.board backOneStep];
            break;
        case 3:
            // TODO:
            break;
        default:
            break;
    }
}
@end
