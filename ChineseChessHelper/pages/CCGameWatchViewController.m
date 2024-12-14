//
//  CCGameWatchViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCGameWatchViewController.h"
#import "CCChessBoard.h"
#import "CCMoveListView.h"
#import "CCToolbar.h"
#import "CCPlayerView.h"
#import "CCChessUtil.h"
#import "UIView+CCFast.h"
#import "CCChesscore.h"
#import "CCGameSearchResultViewController.h"
#import "Toast.h"
#import "EngineWrapper.h"
#import "CCPonderView.h"


#define PLAYER_VIEW_HEIGHT (0) //(30)
#define TOOLBAR_HEIGHT (40)
#define MOVE_LIST_WIDTH (100)

@interface CCGameWatchViewController () <CCToolbarDelegate, EngineWrapperDelegate>

@property (nonatomic, strong) CCGame *game;
@property (nonatomic, strong) CCPlayRecord *record;

@property (nonatomic, strong) CCChessBoard *board;
@property (nonatomic, strong) CCMoveListView *moveListView;
@property (nonatomic, strong) CCToolbar *toolbar;
@property (nonatomic, strong) CCPlayerView *redPlayerView;
@property (nonatomic, strong) CCPlayerView *blackPlayerView;
@property (nonatomic, strong) UILabel *arrangeLabel;

@property (nonatomic, assign) BOOL isAutoPlaying;

@property (nonatomic, strong) CCPonderView *ponderView;
@property (nonatomic, assign) CGSize boardRegularSize;

@end

@implementation CCGameWatchViewController

- (instancetype)initWithGame:(CCGame *)game
{
    self = [super init];
    if (self) {
        self.game = game;
    }
    return self;
}

- (instancetype)initWithRecord:(CCPlayRecord *)record
{
    self = [super init];
    if (self) {
        self.record = record;
    }
    return self;
}

- (NSString *)moveList
{
    if (self.game) {
        return self.game.moveList;
    }
    return self.record.moveList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.game != nil) {
        if (self.game.redPlayer.name.length > 0 && ![self.game.redPlayer.name isEqualToString:@"__noname__"]) {
            self.title = [NSString stringWithFormat:@"%@ %@ %@", self.game.redPlayer.name, [self.game.result isEqualToString:@"黑胜"] ? @"负".localized : ([self.game.result isEqualToString:@"红胜"] ? @"胜".localized : @"和".localized), self.game.blackPlayer.name];
        } else {
            self.title = self.game.title;
        }
        
        if (![self.game.arrangement.name isEqualToString:@"__noname__"]) {
            self.arrangeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            self.arrangeLabel.text = [NSString stringWithFormat:@"%@ %@", self.game.arrangement.name, self.game.arrangement.branch];
            self.arrangeLabel.textAlignment = NSTextAlignmentCenter;
            self.arrangeLabel.font = [UIFont systemFontOfSize:18];
            self.arrangeLabel.numberOfLines = 1;
            self.arrangeLabel.adjustsFontSizeToFitWidth = YES;
            [self.view addSubview:self.arrangeLabel];
            [self.arrangeLabel sizeToFit];
        }
    } else {
        
    }
    
    self.board = [[CCChessBoard alloc] initWithFrame:CGRectZero];
    self.board.mode = CCChessboardMode_Watch;
    self.board.moveList = self.moveList;
    if (self.game != nil) {
        self.board.initialPhase = self.game.initialPhase;
        self.board.currentMoveIndex = self.game.moveIndex;
    }
    __weak typeof(self) weakSelf = self;
    self.board.frameChangeAction = ^{
        if (weakSelf) {
            [weakSelf layoutBoardAgain];
        }
    };
    [self.view addSubview:self.board];
    
    self.toolbar = [[CCToolbar alloc] initWithFrame:CGRectZero
                                       buttonTitles:@[@"开局".localized,
                                                      @"终局".localized,
                                                      @"上一步".localized,
                                                      @"下一步".localized,
                                                      @"自动".localized,
                                                      @"分析".localized,
                                                      @"着法列表".localized]
                                           delegate:self];
    self.toolbar.cc_delegate = self;
    [self.view addSubview:self.toolbar];
    
    self.moveListView = [[CCMoveListView alloc] initWithFrame:CGRectZero];
    self.moveListView.alpha = 1.0f;
    if (self.game) {
        self.moveListView.translatedMoves = [CCChessUtil translateMoveList2FriendlyWord:self.game.moveList withInitialPhase:self.game.initialPhase];
    } else if (self.record) {
        self.moveListView.translatedMoves = [CCChessUtil translateMoveList2FriendlyWord:self.record.moveList withInitialPhase:nil];
    }
    self.moveListView.moveSelectAction = ^(int moveIndex) {
        if (!weakSelf) return;
        [weakSelf.board setCurrentMoveIndex:moveIndex];
        [weakSelf analysis];
        [weakSelf updateToolBarButtonEnableStatus];
    };
    [self.view addSubview:self.moveListView];
    
    if (self.game) {
        [self.moveListView updateSelectedIndex:self.game.moveIndex];
    }
    
    [self setRightButton:@"相同局面".localized image:nil target:self action:@selector(samePhaseSearch)];
    
    [self setupEngine];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.moveListView.translatedMoves.count == 0) {
        [[UIApplication.sharedApplication.delegate window] makeToast:@"棋谱已损坏".localized];
        [self.navigationController popViewControllerAnimated:true];
        return;
    }
    
    [self updateToolBarButtonEnableStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[EngineWrapper shared] stop];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.arrangeLabel.frame = CGRectMake(self.view.safeAreaInsets.left,  self.view.safeAreaInsets.top + 10, self.view.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.arrangeLabel.height);
    
    if (self.board.width == 0) {
        self.board.frame = CGRectMake(self.view.safeAreaInsets.left, self.view.safeAreaInsets.top, self.view.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - TOOLBAR_HEIGHT - AD_HEIGHT - self.arrangeLabel.height - 20);
    }
    
    self.toolbar.frame = CGRectMake(self.view.safeAreaInsets.left, self.board.bottom, self.view.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, TOOLBAR_HEIGHT);
}

- (void)layoutBoardAgain
{
    if (self.ponderView != nil ) {
        self.board.left = (self.view.width - self.board.width) * 0.5;
        self.board.top = self.ponderView.bottom + 5;
    } else {
        self.board.center = CGPointMake(self.view.width * 0.5, (self.view.height + self.view.safeAreaInsets.top - AD_HEIGHT - TOOLBAR_HEIGHT) * 0.5 + self.arrangeLabel.height * 0.5 + 10);
    }
    self.toolbar.frame = CGRectMake(0, self.board.bottom, self.view.width, TOOLBAR_HEIGHT);
    self.moveListView.frame = CGRectMake(self.view.width, self.board.top, MOVE_LIST_WIDTH, self.board.height);
}

- (void)updateToolBarButtonEnableStatus
{
    [self.toolbar updateEnable:self.board.currentMoveIndex > 0 forButtonAt:0];
    [self.toolbar updateEnable:self.board.currentMoveIndex > 0 forButtonAt:2];
    [self.toolbar updateEnable:self.board.currentMoveIndex < self.moveList.length / 4 forButtonAt:1];
    [self.toolbar updateEnable:self.board.currentMoveIndex < self.moveList.length / 4 forButtonAt:3];
}

- (float)autoPlayDelay
{
    return [CCChesscore core].autoPlayDelay;
}

- (void)samePhaseSearch
{
    CCGameSearchResultViewController *vc = [[CCGameSearchResultViewController alloc] initWithNibName:nil bundle:nil];
    vc.needPaging = YES;
    vc.searchPhase = [self.board genPhasePresentation];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupEngine
{
    [[EngineWrapper shared] setThreadCount:[EngineWrapper shared].maxThreadCount / 2];
    [[EngineWrapper shared] setPVCount:2];
    [EngineWrapper shared].delegate = self;
}

#pragma mark - CCToolbarDelegate
- (void)toolbar:(CCToolbar *)tb clickButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            [self.board reset];
            [self analysis];
            break;
        case 1:
            [self.board toEnd];
            [self analysis];
            break;
        case 2:
            [self.board moveLast];
            [self analysis];
            break;
        case 3:
            [self.board moveNext];
            [self analysis];
            break;
        case 4:
            if (self.isAutoPlaying) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
            } else {
                [self performSelector:@selector(autoPlayNext) withObject:nil afterDelay:0.1];
            }
            self.isAutoPlaying = !self.isAutoPlaying;
            [self updateAutoPlayButton];
            break;
        case 5:
            if (!self.ponderView) {
                [self showPonderView];
                [self analysis];
            } else {
                [self hidePonderView];
            }
            break;
        case 6:
            if (self.moveListView.left >= self.view.width) {
                // 当前隐藏状态，现在展示
                [UIView animateWithDuration:0.25 animations:^{
                    self.moveListView.frame = CGRectMake(self.view.width - MOVE_LIST_WIDTH, self.board.top, MOVE_LIST_WIDTH, self.board.height);
                }];
                [self.toolbar updateSelected:YES forButtonAt:6];
            } else {
                [UIView animateWithDuration:0.25 animations:^{
                    self.moveListView.frame = CGRectMake(self.view.width, self.board.top, MOVE_LIST_WIDTH, self.board.height);
                }];
                [self.toolbar updateSelected:NO forButtonAt:6];
            }
            break;
        default:
            break;
    }
    
    [self.moveListView updateSelectedIndex:self.board.currentMoveIndex];
    [self updateToolBarButtonEnableStatus];
    
    if (index != 4 && self.isAutoPlaying) {
        self.isAutoPlaying = NO;
        [self updateAutoPlayButton];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)autoPlayNext
{
    if (self.board.currentMoveIndex < self.moveList.length / 4) {
        [self.board moveNext];
        [self analysis];
        [self.moveListView updateSelectedIndex:self.board.currentMoveIndex];
        [self updateToolBarButtonEnableStatus];
    }
    
    if (self.board.currentMoveIndex < self.moveList.length / 4) {
        [self performSelector:@selector(autoPlayNext) withObject:nil afterDelay: [self autoPlayDelay]];
        self.isAutoPlaying = YES;
    } else {
        self.isAutoPlaying = NO;
    }
    [self updateAutoPlayButton];
}

- (void)updateAutoPlayButton
{
    if (self.isAutoPlaying) {
        [self.toolbar updateTitle:@"停止".localized forButtonAt:4];
    } else {
        [self.toolbar updateTitle:@"自动".localized forButtonAt:4];
    }
}

- (void)analysis
{
    if (self.ponderView == nil) return;
    
    [self.ponderView reset];
    
    NSString *fen = [self.board genPositionFen];
    if (self.game != nil) {
        self.ponderView.initialPhase = self.game.initialPhase;
    } else {
        self.ponderView.initialPhase = nil;
    }
    self.ponderView.moves = [[self moveList] substringToIndex:self.board.currentMoveIndex * 4];
    
    [[EngineWrapper shared] goPonder:fen depth:[CCChesscore core].analyzaDepth];
}

- (void)showPonderView
{
    if (!self.ponderView) {
        self.ponderView = [[CCPonderView alloc] initWithFrame:CGRectMake(-self.view.width, self.view.safeAreaInsets.top + 8, self.view.width - 16, self.board.top - self.view.safeAreaInsets.top - 16)];
        self.ponderView.boardSize = self.board.frame.size;
        [self.view addSubview:self.ponderView];
        
        if (CGSizeEqualToSize(CGSizeZero, self.boardRegularSize)) {
            self.boardRegularSize = self.board.frame.size;
        }
        
        if (self.ponderView.height < 100) {
            CGFloat diff = 100 - self.ponderView.height;
            
            CGFloat rate = self.boardRegularSize.height / self.boardRegularSize.width;
            CGFloat widthDiff = diff / rate;
            
            self.board.size = CGSizeMake(self.board.width - widthDiff, self.board.height - diff);
            
            self.ponderView.height = 100;
            
            [self.board relayout];
            
            [self layoutBoardAgain];
        }
    }
    
    if (self.ponderView.left < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.ponderView setLeft:8];
        }];
    }
    
    [self.toolbar updateSelected:YES forButtonAt:5];
}

- (void)hidePonderView
{
    [[EngineWrapper shared] stop];
    if (self.ponderView && self.ponderView.left > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.ponderView.left = -self.view.width;
        } completion:^(BOOL finished) {
            [self.ponderView removeFromSuperview];
            self.ponderView = nil;
            
            if (!CGSizeEqualToSize(self.board.frame.size, self.boardRegularSize)) {
                self.board.size = self.boardRegularSize;
                [self.board relayout];
                [self layoutBoardAgain];
            }
        }];
        
        [self.toolbar updateSelected:NO forButtonAt:5];
    }
    
}

#pragma mark - PikafishWrapperDelegate
- (void)wrapper:(EngineWrapper *)pf onUpdateFull:(PikafishFullInfo *)info
{
    [self.ponderView updateInfo:info];
}

- (void)wrapper:(EngineWrapper *)pf onUpdateNoMoves:(PikafishShortInfo *)info
{
    
}

@end
