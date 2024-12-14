//
//  CCPlayViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2023/10/27.
//  Copyright © 2023 sheehangame. All rights reserved.
//

#import "CCPlayViewController.h"
#import "CCChessBoard.h"
#import "CCChessUtil.h"
#import "UIView+CCFast.h"
#import "CCToolbar.h"
#import "CCChesscore.h"
#import "EngineWrapper.h"
#import "Toast/Toast.h"
#import "CCPonderView.h"

#define TOOLBAR_HEIGHT (40)

@interface CCPlayViewController () <CCToolbarDelegate, EngineWrapperDelegate>

@property (nonatomic, strong) CCChessBoard *board;
@property (nonatomic, strong) CCToolbar *toolbar;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) CCEngineSetting *engineSetting;
@property (nonatomic, strong, nullable) NSString *moveList;
@property (nonatomic, strong, nullable) PikafishFullInfo *lastBestInfo;
@property (nonatomic, strong, nullable) PikafishFullInfo *bestInfo;

@property (nonatomic, assign) BOOL gameOver;

@property (nonatomic, assign) BOOL didStart;

@property (nonatomic, assign) BOOL thinking;

@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, assign) int timerCounter;

@property (nonatomic, assign) NSTimeInterval startPlayTime;

@property (nonatomic, strong) CCPonderView *ponderView;
@property (nonatomic, assign) CGSize boardRegularSize;

@property (nonatomic, copy) NSString *comment;

@end

@implementation CCPlayViewController

- (instancetype)initWithEngine:(CCEngineSetting *)engine moveList:(NSString *)ml;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.engineSetting = engine;
        self.moveList = ml;
        
        [EngineWrapper shared].delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startPlayTime = [[NSDate date] timeIntervalSince1970];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (self.engineSetting.color == CCEngineColor_None) {
        self.toolbar = [[CCToolbar alloc] initWithFrame:CGRectZero buttonTitles:@[@"重来".localized, @"悔棋".localized, @"分析".localized] delegate:self];
    } else {
        self.toolbar = [[CCToolbar alloc] initWithFrame:CGRectZero buttonTitles:@[@"重来".localized, @"悔棋".localized] delegate:self];
    }
    [self.view addSubview:self.toolbar];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.numberOfLines = 0;
    [self.view addSubview:self.infoLabel];
    
    self.board = [[CCChessBoard alloc] initWithFrame:CGRectZero];
    self.board.mode = self.engineSetting.color == CCEngineColor_None ? CCChessboardMode_SelfPlay : CCChessboardMode_Play;
    self.board.isBlack = self.engineSetting.color == CCEngineColor_Red;
    __weak typeof(self) weakSelf = self;
    self.board.frameChangeAction = ^{
        if (weakSelf) {
            [weakSelf layoutBoardAgain];
        }
    };
    
    if (self.board.isBlack) {
        [self.board up2Down];
    }
    
    self.board.onPlayedAction = ^{
        if (weakSelf) {
            [weakSelf computerGo];

            [weakSelf analysis];
        }
    };
    
    self.board.checkMove = ^BOOL(NSString * positionFen, NSString *moveFen) {
        return [[EngineWrapper shared] checkMoveLegal:moveFen atPosition:positionFen];
    };
    [self.view addSubview:self.board];
        
    self.navigationItem.rightBarButtonItems = @[
        [self barButtonItem:@"备注".localized image:nil target:self action:@selector(addComment)],
        [self barButtonItem:@"保存".localized image:nil target:self action:@selector(saveGame)],
    ];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.board.width == 0) {
        self.board.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - TOOLBAR_HEIGHT - AD_HEIGHT);
    }
    self.toolbar.frame = CGRectMake(0, self.board.bottom, self.view.width, TOOLBAR_HEIGHT);
    self.infoLabel.frame = CGRectMake(12, 8, self.view.width - 24, self.board.top - 12);
}

- (void)layoutBoardAgain
{
    if (self.ponderView != nil ) {
        self.board.left = (self.view.width - self.board.width) * 0.5;
        self.board.top = self.ponderView.bottom + 5;
    } else {
        self.board.center = CGPointMake(self.view.width * 0.5, (self.view.height + self.view.safeAreaInsets.top - AD_HEIGHT - TOOLBAR_HEIGHT) * 0.5);
    }
    self.toolbar.frame = CGRectMake(0, self.board.bottom, self.view.width, TOOLBAR_HEIGHT);
    self.infoLabel.frame = CGRectMake(12, 8, self.view.width - 24, self.board.top - 4 - 8);
}

- (void)backAction
{
    if (self.gameOver) {
        [super backAction];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示".localized message:@"当前对弈中，确定退出？".localized preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    weakify(self)
    [alert addAction:[UIAlertAction actionWithTitle:@"退出".localized style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (weak_self == nil) return;
        [super backAction];
    }]];
    
    [self presentViewController:alert animated:true completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.didStart) {
        if (self.moveList.length > 0) {
            self.board.moveList = self.moveList;
            [self.board reset];
            [self.board toEnd];
            [[CCChesscore core] clearLastPlay:self.engineSetting.color == CCEngineColor_None];
        }
        
        [[EngineWrapper shared] setThreadCount:self.engineSetting.threads];
        if (self.engineSetting.color == CCEngineColor_None) {
            [[EngineWrapper shared] setPVCount:2];
        }
        
        [[EngineWrapper shared] start];
        if (self.engineSetting.color != CCEngineColor_None) {
            if ((self.engineSetting.color == CCEngineColor_Red && self.moveList.length == 0)
                || (self.board.currentMoveIndex % 2 == 0 && self.engineSetting.color == CCEngineColor_Red)
                || (self.board.currentMoveIndex % 2 == 1 && self.engineSetting.color == CCEngineColor_Black)) {
                [self computerGo];
            }
        }
        
        self.didStart = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self clear];
    if (!self.gameOver) {
        [self saveUnfinishedGame];
    }
}

- (NSString *)getRedScore
{
    BOOL isRed = self.engineSetting.color == CCEngineColor_Red;
    if (self.engineSetting.color == CCEngineColor_None) {
        isRed = (self.board.moveRecords.count % 2) == 0;
    }
    
    if (self.bestInfo) {
        return [self.bestInfo displayScore:isRed];
    }
    
    if (self.engineSetting.color == CCEngineColor_None) {
        isRed = !isRed;
    }
    return [self.lastBestInfo displayScore:isRed];
}

- (CCGameVictoryType)getGameResult
{
    if (!self.gameOver) return Unfinished;
    
    NSString *score = [self getRedScore];
    if ([score rangeOfString:@"黑方".localized].location != NSNotFound) {
        return Black;
    } else if ([score rangeOfString:@"红方".localized].location != NSNotFound) {
        return Red;
    } else if ([score intValue] > 0) {
        return Red;
    } else if ([score intValue] < 0) {
        return Black;
    }
    return Tie;
}

- (void)updateInfoLabel
{
    if (self.bestInfo != nil) {
        float win, draw, lose = 0;
        [self.bestInfo getWinRate:&win drawRate:&draw loseRate:&lose];
        
        NSMutableString *text = [NSMutableString string];
        BOOL isRed = self.engineSetting.color == CCEngineColor_Red;
        if (self.engineSetting.color == CCEngineColor_None) {
            isRed = (self.board.moveRecords.count % 2) == 0;
        }
        [text appendFormat:@"%@: %@\n", @"评分".localized, [self.bestInfo displayScore: isRed]];
        
        self.infoLabel.text = text;
    }
}

- (void)updateThinking
{
    if (self.thinking) {
        if (self.timer) return;
        
        weakify(self)
        self.timerCounter = 1;
        [self updateTitle];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (!weak_self) return;
            
            weak_self.timerCounter++;
            if (weak_self.timerCounter == 4) {
                weak_self.timerCounter = 1;
            }
            [weak_self updateTitle];
        }];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        self.timerCounter = 0;
        [self updateTitle];
    }
}

- (void)updateTitle
{
    if (self.timerCounter == 0) {
        self.title = @"对弈".localized;
    } else {
        NSMutableString *rslt = [NSMutableString stringWithString:@"对弈".localized];
        [rslt appendString:@"("];
        
        for (int i = 0; i < self.timerCounter; i++) {
            [rslt appendString:@"."];
        }
        [rslt appendString:@")"];
        
        self.title = rslt;
    }
}

- (void)computerGo
{
    if (self.gameOver) return;
    if (self.engineSetting.color == CCEngineColor_Red && self.board.moveRecords.count % 2 == 1) return;
    if (self.engineSetting.color == CCEngineColor_Black && self.board.moveRecords.count % 2 == 0) return;
    
    NSString *fen = [self.board getPhaseFenPresentation];
    self.lastBestInfo = self.bestInfo;
    self.bestInfo = nil;
    [[EngineWrapper shared] position:fen currentMove:nil goTime:self.engineSetting.goTime goDepth:self.engineSetting.goDepth];
    
    self.thinking = YES;
    [self updateThinking];
}

- (void)clear
{
    [[EngineWrapper shared] stop];
}

- (void)dealWithGameOver
{
    [[EngineWrapper shared] stop];
    self.thinking = NO;
    self.gameOver = YES;
    self.board.userInteractionEnabled = NO;
    
    weakify(self)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示".localized message:@"棋局结束，是否保存记录？".localized preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weak_self.navigationController popViewControllerAnimated:true];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"保存".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!weak_self) return;
        [weak_self saveGame];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weak_self.navigationController popViewControllerAnimated:true];
        });
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)saveGame
{
    CCPlayRecord *record = [CCPlayRecord new];
    record.computerColor = self.engineSetting.color;
    record.moveList = [self.board getPrivateMoveList];
    if (self.startPlayTime != 0) {
        record.playTime = self.startPlayTime;
    } else {
        record.playTime = [[NSDate date] timeIntervalSince1970];
    }
    record.result = [self getGameResult];
    record.comment = self.comment;
    
    DLog(@"game result: %lu", record.result);
    
    [[CCChesscore core] saveRecord:record];
    
    [self toast:@"保存成功".localized];
}

- (void)addComment
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"备注".localized message:nil preferredStyle:UIAlertControllerStyleAlert];
    weakify(alert)
    weakify(self)
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = weak_self.comment;
        textField.returnKeyType = UIReturnKeyDone;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消".localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定".localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *comment = [weak_alert.textFields.firstObject text];
        if (comment) {
            weak_self.comment = comment;
        }
    }]];
    
    [self.navigationController presentViewController:alert animated:YES completion:NULL];
}

- (void)saveUnfinishedGame
{
    if (self.gameOver) return;
    if (self.board.mode != CCChessboardMode_Play && self.board.mode != CCChessboardMode_SelfPlay) return;
    
    NSString *moveList = [self.board getPrivateMoveList];
    if (!moveList || moveList.length <= 0) return;
    
    CCPlayUnfinishedModel *model = [CCPlayUnfinishedModel new];
    model.setting = self.engineSetting;
    model.moveList = moveList;
    
    [[CCChesscore core] saveLastPlay:model isSelfPlay:self.board.mode == CCChessboardMode_SelfPlay];
}

- (void)analysis
{
    if (self.engineSetting.color != CCEngineColor_None) return;
    if (self.ponderView == nil) return;
    
    [self.ponderView reset];
    
    NSString *fen = [self.board genPositionFen];
    
    self.ponderView.moves = [self.board getPrivateMoveList];
    
    [[EngineWrapper shared] goPonder:fen depth:self.engineSetting.goDepth];
}

- (void)showPonderView
{
    if (self.engineSetting.color != CCEngineColor_None) return;
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
    
    [self.toolbar updateSelected:YES forButtonAt:2];
}

- (void)hidePonderView
{
    if (self.engineSetting.color != CCEngineColor_None) return;
    
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
        
        [self.toolbar updateSelected:NO forButtonAt:2];
    }
}


#pragma mark -
- (void)toolbar:(CCToolbar *)tb clickButtonAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            [self.board reset];
            self.startPlayTime = [[NSDate date] timeIntervalSince1970];
            break;
        case 1:
            [self.board backOneStep];
            [self analysis];
            break;
        case 2:
            if (!self.ponderView) {
                [self showPonderView];
                [self analysis];
            } else {
                [self hidePonderView];
            }
            break;
    }
    self.gameOver = NO;
    self.board.userInteractionEnabled = YES;
    [self computerGo];
}

#pragma mark - PikafishWrapperDelegate
- (void)wrapper:(EngineWrapper *)pf bestMove:(NSString *)bm ponder:(NSString *)p
{
    self.thinking = NO;
    
    if ([bm isEqualToString:@"(none)"]) {
        return;
    }
    
    if (p.length < 4 && self.engineSetting.color != CCEngineColor_None) {
        [self dealWithGameOver];
    }
    
    if (self.engineSetting.color != CCEngineColor_None) {
        [self.board performFenString:bm];
    }
    [self updateInfoLabel];
    [self updateThinking];
}

- (void)wrapper:(EngineWrapper *)pf onUpdateFull:(PikafishFullInfo *)info
{
    if (self.bestInfo == nil || info.depth > self.bestInfo.depth) {
        self.bestInfo = info;
    }
    
    [self.ponderView updateInfo:info];
}

- (void)wrapper:(EngineWrapper *)pf onUpdateNoMoves:(PikafishShortInfo *)info
{
    [self dealWithGameOver];
    [self updateInfoLabel];
    [self updateThinking];
}

@end
