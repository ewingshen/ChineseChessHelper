//
//  CCChessBoard.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCChessBoard.h"
#import "CCChessUtil.h"
#import "CCChessmanButton.h"
#import "UIView+CCFast.h"
#import "CCMoveItem.h"
#import "CCChesscore.h"
#import "Toast.h"

CGSize chessManOriSize(int type) {
    switch (type) {
        case 0:
            return CGSizeMake(212, 212);
        case 1:
            return CGSizeMake(54, 54);
        case 2:
            return CGSizeMake(80, 80);
    }
    return CGSizeZero;
}

CGSize chessBoardOriSize(int type) {
    switch (type) {
        case 0:
            return CGSizeMake(2193, 2412);
        case 1:
            return CGSizeMake(507, 567);
        case 2:
            return CGSizeMake(900, 1000);
    }
    return CGSizeZero;
}

CGPoint chessBoardLeftTop(int type) {
    switch (type) {
        case 0:
            return CGPointMake(145, 145);
        case 1:
            return CGPointMake(21, 24);
        case 2:
            return CGPointMake(50, 50);
    }
    return CGPointZero;
}

CGSize chessBoardBoxSize(int type) {
    switch (type) {
        case 0:
            return CGSizeMake(235, 235);
        case 1:
            return CGSizeMake(57, 57);
        case 2:
            return CGSizeMake(100, 100);
    }
    return CGSizeZero;
}

static float animateDuration = 0.25f;

NSString *chessBoardImage(int type) {
    return [NSString stringWithFormat:@"cb%d", type];
}

#define CHESS_MAN_ORI_SIZE chessManOriSize([CCChesscore core].chessboardType)
#define CHESS_BOARD_ORI_SIZE chessBoardOriSize([CCChesscore core].chessboardType)
#define CHESS_BOARD_TOTAL_HOR_PADDING (20)
#define CHESS_BOARD_LEFT_TOP chessBoardLeftTop([CCChesscore core].chessboardType)
#define CHESS_BOARD_BOX_SIZE chessBoardBoxSize([CCChesscore core].chessboardType)

#define RED_CHESSMAN_TAG_BASE (100)
#define BLACK_CHESSMAN_TAG_BASE (200)

@interface CCChessBoard ()

@property (nonatomic, strong) UIImageView *board;
@property (nonatomic, strong) NSMutableArray<CCChessmanButton *> *redChessmans;
@property (nonatomic, strong) NSMutableArray<CCChessmanButton *> *blackChessmans;

@property (nonatomic, strong) UIImageView *redBox;
@property (nonatomic, strong) UIImageView *blackBox;
/// key是棋子的tag，value是当前位置的intValue。
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *positionInfos;

@property (nonatomic, strong) CCChessmanButton *selectedChessman;

@property (nonatomic, strong) NSMutableArray<CCMoveItem*> *moveRecords;
@property (nonatomic, strong) NSMutableArray<CCPhaseFen *> *phaseFen;

@end

@implementation CCChessBoard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.positionInfos = [NSMutableDictionary dictionary];
        self.moveRecords = [NSMutableArray array];
        _currentMoveIndex = -2;
        [self setupView];
        
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setupView
{
    self.board = [[UIImageView alloc] initWithImage:[UIImage imageNamed:chessBoardImage([CCChesscore core].chessboardType)]];
    [self addSubview:self.board];
    self.board.frame = self.bounds;
    self.board.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(boardTapAction:)];
    [self.board addGestureRecognizer:tap];
    
    // red
    self.redChessmans = [NSMutableArray arrayWithCapacity:16];
    NSArray<NSNumber *> *redMans = @[
        @(CCChessmanType_Red_Ju), @(CCChessmanType_Red_Ma), @(CCChessmanType_Red_Xiang), @(CCChessmanType_Red_Shi), @(CCChessmanType_Red_Shuai), @(CCChessmanType_Red_Shi), @(CCChessmanType_Red_Xiang), @(CCChessmanType_Red_Ma), @(CCChessmanType_Red_Ju), @(CCChessmanType_Red_Pao), @(CCChessmanType_Red_Pao), @(CCChessmanType_Red_Bing), @(CCChessmanType_Red_Bing), @(CCChessmanType_Red_Bing), @(CCChessmanType_Red_Bing), @(CCChessmanType_Red_Bing)
    ];
    for (int i = 0; i < redMans.count; i++) {
        CCChessmanType t = [redMans[i] integerValue];
        
        CCChessmanButton *button = [self buttonWithType:t action:@selector(redAction:)];
        [self.redChessmans addObject:button];
        button.tag = RED_CHESSMAN_TAG_BASE + i;
        [self addSubview:button];
    }
    
    self.blackChessmans = [NSMutableArray arrayWithCapacity:16];
    NSArray *blackMans = @[
        @(CCChessmanType_Black_Ju), @(CCChessmanType_Black_Ma), @(CCChessmanType_Black_Xiang), @(CCChessmanType_Black_Shi), @(CCChessmanType_Black_Jiang), @(CCChessmanType_Black_Shi), @(CCChessmanType_Black_Xiang), @(CCChessmanType_Black_Ma), @(CCChessmanType_Black_Ju), @(CCChessmanType_Black_Pao), @(CCChessmanType_Black_Pao), @(CCChessmanType_Black_Zu), @(CCChessmanType_Black_Zu), @(CCChessmanType_Black_Zu), @(CCChessmanType_Black_Zu), @(CCChessmanType_Black_Zu)
    ];
    for (int i = 0; i < blackMans.count; i++) {
        CCChessmanType t = [blackMans[i] integerValue];
        
        CCChessmanButton *button = [self buttonWithType:t action:@selector(blackAction:)];
        [self.blackChessmans addObject:button];
        button.tag = BLACK_CHESSMAN_TAG_BASE + i;
        [self addSubview:button];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize bh = [self boardSize:NO];
    CGSize bv = [self boardSize:YES];
    
    CGFloat adjustedHeight = 0;
    CGFloat adjustedWidth = 0;
    if (bh.width > bv.width) {
        // 棋子排布在左右两侧
        self.board.frame = CGRectMake((self.width - bh.width) * 0.5, (self.height - bh.height) * 0.5, bh.width, bh.height);
        
        CGFloat scale = CHESS_BOARD_ORI_SIZE.width / bh.width;
        CGFloat chessManSize = CHESS_MAN_ORI_SIZE.width / scale;
        NSInteger countPerColumn = 8;
        CGFloat chessManVerPadding = (bh.height - countPerColumn * chessManSize) / (countPerColumn - 1);
        CGFloat chessManHorPadding = CHESS_BOARD_TOTAL_HOR_PADDING / 4.0f;
        
        NSInteger redIndex = 0;
        for (CCChessmanButton *btn in self.redChessmans) {
            NSNumber *pos = self.positionInfos[@(btn.tag)];
            CCPosition p = [pos intValue];
            if (pos && p != CCDeadPosition) {
                btn.frame = [self frame4ChessmanAtPosition:p];
                btn.hidden = NO;
            } else {
                btn.frame = CGRectMake(self.board.right + chessManHorPadding + (redIndex / countPerColumn) * (chessManSize + chessManHorPadding), self.board.top + (redIndex % countPerColumn) * (chessManSize + chessManVerPadding), chessManSize, chessManSize);
                btn.hidden = self.mode != CCChessboardMode_Edit;
            }
            
            redIndex += 1;
        }
        
        NSInteger blackIndex = 0;
        for (CCChessmanButton *btn in self.blackChessmans) {
            NSNumber *pos = self.positionInfos[@(btn.tag)];
            CCPosition p = [pos intValue];
            if (pos && p != CCDeadPosition) {
                btn.frame = [self frame4ChessmanAtPosition:p];
                btn.hidden = NO;
            } else {
                btn.frame = CGRectMake(self.board.left - (blackIndex / countPerColumn + 1) * (chessManSize + chessManHorPadding), self.board.top + (blackIndex % countPerColumn) * (chessManSize + chessManVerPadding), chessManSize, chessManSize);
                
                btn.hidden = self.mode != CCChessboardMode_Edit;
            }
            
            blackIndex += 1;
        }
        
        adjustedHeight = bh.height;
        if (self.mode == CCChessboardMode_Edit) {
            adjustedWidth = bh.width + CHESS_BOARD_TOTAL_HOR_PADDING + chessManSize * 4;
        } else {
            adjustedWidth = bh.width;
        }
    } else {
        self.board.frame = CGRectMake((self.width - bv.width) * 0.5, (self.height - bv.height) * 0.5, bv.width, bv.height);
        
        CGFloat scale = CHESS_BOARD_ORI_SIZE.width / bv.width;
        CGFloat chessManSize = CHESS_MAN_ORI_SIZE.width / scale;
        NSInteger countPerRow = 8;
        CGFloat chessManVerPadding = CHESS_BOARD_TOTAL_HOR_PADDING / 4.0f;
        CGFloat chessManHorPadding = (bv.width - chessManSize * countPerRow) / (countPerRow - 1);
        
        NSInteger redIndex = 0;
        for (CCChessmanButton *btn in self.redChessmans) {
            NSNumber *pos = self.positionInfos[@(btn.tag)];
            CCPosition p = [pos intValue];
            if (pos && p != CCDeadPosition) {
                btn.frame = [self frame4ChessmanAtPosition:p];
                btn.hidden = NO;
            } else {
                btn.frame = CGRectMake((redIndex % countPerRow) * (chessManSize + chessManHorPadding) + self.board.left, self.board.bottom + chessManVerPadding + (redIndex / countPerRow) * (chessManSize + chessManVerPadding), chessManSize, chessManSize);
                btn.hidden = self.mode != CCChessboardMode_Edit;
            }
            redIndex += 1;
        }
        
        NSInteger blackIndex = 0;
        for (CCChessmanButton *btn in self.blackChessmans) {
            NSNumber *pos = self.positionInfos[@(btn.tag)];
            CCPosition p = [pos intValue];
            if (pos && p != CCDeadPosition) {
                btn.frame = [self frame4ChessmanAtPosition:p];
                btn.hidden = NO;
            } else {
                btn.frame = CGRectMake((blackIndex % countPerRow) * (chessManSize + chessManHorPadding) + self.board.left, self.board.top - (blackIndex / countPerRow + 1) * (chessManSize + chessManVerPadding), chessManSize, chessManSize);
                btn.hidden = self.mode != CCChessboardMode_Edit;
            }
            blackIndex += 1;
        }
        
        adjustedWidth = bv.width;
        if (self.mode == CCChessboardMode_Edit) {
            adjustedHeight = bv.height + chessManSize * 4 + CHESS_BOARD_TOTAL_HOR_PADDING;
        } else {
            adjustedHeight = bv.height;
        }
    }
    
    if ((int)self.height != (int)adjustedHeight || (int)self.width != (int)adjustedWidth) {
        DLog("board size Changed: %@ -> %@", NSStringFromCGSize(self.frame.size), NSStringFromCGSize(CGSizeMake(adjustedWidth, adjustedHeight)));
        
        self.frame = CGRectMake(self.left, self.top, adjustedWidth, adjustedHeight);
        CALL_BLOCK(self.frameChangeAction)
        [self relayout];
    }
}

#pragma mark - Private
- (CCChessmanButton *)chessmanAtPosition:(CCPosition)p
{
    for (NSNumber *key in self.positionInfos) {
        if ([self.positionInfos[key] intValue] == p) {
            return [self viewWithTag:[key intValue]];
        }
    }
    
    return nil;
}

- (CCChessmanButton *)buttonWithType:(CCChessmanType)cmt action:(SEL)action
{
    CCChessmanButton *btn = [CCChessmanButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.type = cmt;
    btn.name = [CCChessUtil nameOf:cmt];
    [btn setImage:[UIImage imageNamed:[CCChessUtil spriteNameOf:btn.name type:[CCChesscore core].chessboardType]] forState:UIControlStateNormal];
    
    return btn;
}

- (CGSize)boardSize:(BOOL)isVertical
{
    if (isVertical) {
        if (self.direction == CCChessboardDirection_Hor) return CGSizeZero;
        
        CGFloat horPadding = self.mode == CCChessboardMode_Edit ? CHESS_BOARD_TOTAL_HOR_PADDING : 0;
        CGFloat boardHeight = self.height - horPadding;
        CGFloat boardWidth = self.width;
        
        CGFloat ratio = boardWidth / boardHeight;
        CGSize chessmanSize = self.mode == CCChessboardMode_Edit ? CHESS_MAN_ORI_SIZE : CGSizeZero;
        CGFloat fixedRatio = CHESS_BOARD_ORI_SIZE.width / (CHESS_BOARD_ORI_SIZE.height + chessmanSize.height * 4);
        CGFloat boardRatio = CHESS_BOARD_ORI_SIZE.width / CHESS_BOARD_ORI_SIZE.height;
        
        if (fixedRatio > ratio) {
            // 说明实际尺寸的宽度比较小，必须以实际尺寸的宽为基准
            boardHeight = boardWidth / boardRatio;
        } else {
            boardHeight *= CHESS_BOARD_ORI_SIZE.height / (CHESS_BOARD_ORI_SIZE.height + chessmanSize.height * 4);
            boardWidth = boardHeight * boardRatio;
        }
        
        return CGSizeMake(boardWidth, boardHeight);
    } else {
        if (self.direction == CCChessboardDirection_Ver) return CGSizeZero;
        
        CGFloat horPadding = self.mode == CCChessboardMode_Edit ? CHESS_BOARD_TOTAL_HOR_PADDING : 0;
        CGFloat boardHeight = self.height;
        CGFloat boardWidth = self.width - horPadding;
        
        CGFloat ratio = boardWidth / boardHeight;
        CGSize chessmanSize = self.mode == CCChessboardMode_Edit ? CHESS_MAN_ORI_SIZE : CGSizeZero;
        CGFloat fixedRatio = (CHESS_BOARD_ORI_SIZE.width + chessmanSize.width * 4) / CHESS_BOARD_ORI_SIZE.height;
        CGFloat boardRatio = CHESS_BOARD_ORI_SIZE.width / CHESS_BOARD_ORI_SIZE.height;
        
        if (fixedRatio > ratio) {
            // 说明实际尺寸的宽度比较小，必须以实际尺寸的宽为基准
            boardWidth *= (CHESS_BOARD_ORI_SIZE.width) / (chessmanSize.width * 4 + CHESS_BOARD_ORI_SIZE.width);
            boardHeight = boardWidth / boardRatio;
        } else {
            boardWidth = boardHeight * boardRatio;
        }
        
        return CGSizeMake(boardWidth, boardHeight);
    }
}

- (CGRect)frame4ChessmanAtPosition:(CCPosition)boardPosition
{
    CGFloat scale = CHESS_BOARD_ORI_SIZE.width / self.board.width;
    
    CCPosition c = CCColOfPosition(boardPosition);
    CCPosition r = CCRowOfPosition(boardPosition);
    CGSize chessmanSize = CGSizeApplyAffineTransform(CHESS_MAN_ORI_SIZE, CGAffineTransformMakeScale(1.0 / scale, 1.0 / scale));
    return CGRectMake(self.board.left + (CHESS_BOARD_LEFT_TOP.x + c * CHESS_BOARD_BOX_SIZE.width) / scale - chessmanSize.width * 0.5, self.board.top + (CHESS_BOARD_LEFT_TOP.y + r * CHESS_BOARD_BOX_SIZE.height) / scale - chessmanSize.height * 0.5, chessmanSize.width, chessmanSize.height);
}

- (CCPosition)mostPossiblePosition:(CGPoint)point
{
    CGFloat scale = CHESS_BOARD_ORI_SIZE.width / self.board.width;
    
    uint8_t col = (uint8_t)roundf((point.x - CHESS_BOARD_LEFT_TOP.x / scale) / (CHESS_BOARD_BOX_SIZE.width / scale));
    uint8_t row = (uint8_t)roundf((point.y - CHESS_BOARD_LEFT_TOP.y / scale) / (CHESS_BOARD_BOX_SIZE.height / scale));
    
    return CCMakePosition(row, col);
}

// 本方法的前提是落子位子的合理性
- (BOOL)canMove:(CCChessmanType)cmt fromPosition:(CCPosition)fp toPosition:(CCPosition)tp
{
    assert(fp != CCDeadPosition);
    
    CCChessmanButton *tcm = [self chessmanAtPosition:tp];
    // 1. 判断目标位置是否是己方子力
    if (tcm && isSameCamp(cmt, tcm.type)) {
        return NO;
    }
    
    // 2. 判断行进路线上是否有障碍
    if (cmt == CCChessmanType_Red_Ju || cmt == CCChessmanType_Black_Ju) {
        // 车：直线行走，且路径上不能有个其他子力
        return [self isLinearWay:fp to:tp] && [self chessManCountBetween:fp and:tp] == 0;
    } else if (cmt == CCChessmanType_Red_Pao || cmt == CCChessmanType_Black_Pao) {
        // 炮：两种模式：
        //    1. 走：同车
        //    2. 吃子：隔山打牛
        if (tcm) {
            // case 2
            return [self isLinearWay:fp to:tp] && [self chessManCountBetween:fp and:tp] == 1;
        } else {
            return [self isLinearWay:fp to:tp] && [self chessManCountBetween:fp and:tp] == 0;
        }
    } else if (cmt == CCChessmanType_Red_Ma || cmt == CCChessmanType_Black_Ma) {
        // 马：威风八面，蹩马脚
        CCPosition frow = CCRowOfPosition(fp);
        CCPosition fcol = CCColOfPosition(fp);
        CCPosition trow = CCRowOfPosition(tp);
        CCPosition tcol = CCColOfPosition(tp);
        
        // 分四个方向:上、左、下、右 查找蹩马腿的位置
        CCPosition barrierPosition = CCDeadPosition;
        if (frow - trow == 2 && fabs(fcol - tcol) == 1) {
            barrierPosition = CCMakePosition(frow - 1, fcol);
        } else if (fcol - tcol == 2 && fabs(frow - trow) == 1) {
            barrierPosition = CCMakePosition(frow, fcol - 1);
        } else if (trow - frow == 2 && fabs(fcol - tcol) == 1) {
            barrierPosition = CCMakePosition(frow + 1, fcol);
        } else if (tcol - fcol == 2 && fabs(frow - trow) == 1) {
            barrierPosition = CCMakePosition(frow, fcol + 1);
        }
        
        if (barrierPosition != CCDeadPosition) {
            CCChessmanButton *barrier = [self chessmanAtPosition:barrierPosition];
            return !barrier;
        } else {
            return NO;
        }
    } else if (cmt == CCChessmanType_Black_Xiang || cmt == CCChessmanType_Red_Xiang) {
        // 象眼：((fp.row + tp.row) / 2, (fp.col + tp.col) / 2)
        CCPosition barrierPosition = CCMakePosition((CCRowOfPosition(fp) + CCRowOfPosition(tp)) / 2, (CCColOfPosition(fp) + CCColOfPosition(tp)) / 2);
        CCChessmanButton *barrier = [self chessmanAtPosition:barrierPosition];
        
        return !barrier;
    } else if (cmt == CCChessmanType_Black_Shi || cmt == CCChessmanType_Red_Shi) {
        // 士没有特殊逻辑
        return YES;
    } else if (cmt == CCChessmanType_Black_Zu || cmt == CCChessmanType_Red_Bing) {
        // 1、一次只能走一步
        // 2、只能前进
        // 3、过河后可以横着走
        CCPosition frow = CCRowOfPosition(fp);
        CCPosition fcol = CCColOfPosition(fp);
        CCPosition trow = CCRowOfPosition(tp);
        CCPosition tcol = CCColOfPosition(tp);
        
        // case 1 check
        if (fabs(frow - trow) + fabs(fcol - tcol) == 1) {
            // 先将红方映射为黑方，然后统一处理
            if (cmt == CCChessmanType_Red_Bing) {
                frow = 9 - frow;
                fcol = 8 - fcol;
                trow = 9 - trow;
                tcol = 8 - tcol;
            }
            
            // case 2 check.
            if (trow < frow) {
                return NO;
            }
            
            // case 3 check.
            if (fcol != tcol && frow <= 4) {
                // 横着走了但是还没过河
                return NO;
            }
            
            return YES;
        }
        
        return NO;
    } else if (cmt == CCChessmanType_Black_Jiang || cmt == CCChessmanType_Red_Shuai) {
        // 1、一次只能走一步
        // 2、将帅不能照面
        CCPosition frow = CCRowOfPosition(fp);
        CCPosition fcol = CCColOfPosition(fp);
        CCPosition trow = CCRowOfPosition(tp);
        CCPosition tcol = CCColOfPosition(tp);
        
        // case 1 check.
        if (fabs(frow - trow) + fabs(fcol - tcol) != 1) {
            return NO;
        }
        
        // case 2 check
        CCChessmanButton *anotherKing = nil;
        if (cmt == CCChessmanType_Black_Jiang) {
            anotherKing = [self viewWithTag:RED_CHESSMAN_TAG_BASE + 4];
        } else {
            anotherKing = [self viewWithTag:BLACK_CHESSMAN_TAG_BASE + 4];
        }
        
        CCPosition anotherPositon = [self.positionInfos[@(anotherKing.tag)] intValue];
        
        if (CCColOfPosition(tp) == CCColOfPosition(anotherPositon)) {
            // 存在照面的可能性
            int cmc = [self chessManCountBetween:tp and:anotherPositon];
            return cmc > 0;
        }
        
        return YES;
    }
    
    return YES;
}

- (BOOL)isLinearWay:(CCPosition)fp to:(CCPosition)tp
{
    CCPosition frow = CCRowOfPosition(fp);
    CCPosition fcol = CCColOfPosition(fp);
    CCPosition trow = CCRowOfPosition(tp);
    CCPosition tcol = CCColOfPosition(tp);
    
    return frow == trow || fcol == tcol;
}

// @attentation 此方法有个前提是两个位置确实在一条线上。
- (int)chessManCountBetween:(CCPosition)fp and:(CCPosition)tp
{
    int step = 0;
    if (fabs(tp - fp) <= 8) {
        // 说明在一条横线上
        step = tp > fp ? 1 : -1;
    } else {
        // 竖线
        step = tp > fp ? 9 : -9;
    }
    
    int cmc = 0;
    for (CCPosition p = fp + step; p != tp; p += step) {
        if ([self chessmanAtPosition:p]) {
            cmc++;
        }
    }
    
    return cmc;
}

- (BOOL)checkMoveLegal:(CCPosition)fp to:(CCPosition)tp
{
    if (self.mode != CCChessboardMode_Play && self.mode != CCChessboardMode_SelfPlay) {
        return true;
    }
    
    BOOL legal = true;
    
    if (self.checkMove != NULL) {
        NSString *movefen = [NSString stringWithFormat:@"%@%@", [CCChessUtil FenFromPosition:fp], [CCChessUtil FenFromPosition:tp]];
        NSString *positionFen = [[self getPhaseFenPresentation] stringByReplacingOccurrencesOfString:@"position " withString:@""];
        legal = self.checkMove(positionFen, movefen);
    }
    
    if (!legal) {
        [[UIView keyWindow] makeToast:@"禁止着法".localized];
    }
    
    return legal;
}

- (void)performMove:(CCMoveItem *)mi
{
    if (mi.mainCtx) {
        CCChessmanButton *man = [self viewWithTag:mi.mainCtx.intValue];
        if (mi.to == CCDeadPosition) {
            [self.positionInfos removeObjectForKey:@(man.tag)];
        } else {
            self.positionInfos[@(man.tag)] = @(mi.to);
        }
    }
    
    if (mi.eatedCtx) {
        CCChessmanButton *man = [self viewWithTag:mi.eatedCtx.intValue];
        [self.positionInfos removeObjectForKey:@(man.tag)];
    }
}

- (void)revertMove:(CCMoveItem *)mi
{
    if (mi.mainCtx) {
        CCChessmanButton *man = [self viewWithTag:mi.mainCtx.intValue];
        if (mi.from == CCDeadPosition) {
            [self.positionInfos removeObjectForKey:@(man.tag)];
        } else {
            self.positionInfos[@(man.tag)] = @(mi.from);
        }
    }
    
    if (mi.eatedCtx) {
        CCChessmanButton *eated = [self viewWithTag:mi.eatedCtx.intValue];
        if (mi.to == CCDeadPosition) {
            [self.positionInfos removeObjectForKey:@(eated.tag)];
        } else {
            self.positionInfos[@(eated.tag)] = @(mi.to);
        }
    }
    
    [self relayout];
}
#pragma mark - Event Handler
- (void)redAction:(CCChessmanButton *)sender
{
    if (self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay) {
        if (self.moveRecords.count % 2 != 0 && !self.selectedChessman) {
            return;
        }
        
        if (self.mode == CCChessboardMode_Play && self.isBlack && !self.selectedChessman) {
            return;
        }
    }
    
    [self chessmanAction:sender];
}

- (void)blackAction:(CCChessmanButton *)sender
{
    if (self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay) {
        if (self.moveRecords.count % 2 == 0 && !self.selectedChessman) {
            return;
        }
        
        if (self.mode == CCChessboardMode_Play && !self.isBlack && !self.selectedChessman) {
            return;
        }
    }
    
    [self chessmanAction:sender];
}

- (void)chessmanAction:(CCChessmanButton *)sender
{
    if (self.mode == CCChessboardMode_Watch) return;
    
    sender.selected = !sender.selected;
    
    if (self.selectedChessman == sender) {
        // nothing todo
        self.selectedChessman = sender.selected ? sender : nil;
    } else {
        if (self.mode == CCChessboardMode_Edit) {
            self.selectedChessman.selected = NO;
            self.selectedChessman = sender.selected ? sender : nil;
        } else if (self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay) {
            if (self.selectedChessman) {
                if (isSameCamp(self.selectedChessman.type, sender.type)) {
                    self.selectedChessman.selected = NO;
                    self.selectedChessman = sender.selected ? sender : nil;
                    return;
                }
                
                // 非同阵营，需要判断吃子逻辑
                CCPosition fp = [self.positionInfos[@(self.selectedChessman.tag)] intValue];
                CCPosition tp = [self.positionInfos[@(sender.tag)] intValue];
                
                BOOL canMove = [CCChessUtil checkPositionValid:tp chessmen:self.selectedChessman.type];
                if (canMove) {
                    canMove = [self canMove:self.selectedChessman.type fromPosition:fp toPosition:tp];
                }
                
                if (canMove) {
                    canMove = [self checkMoveLegal:fp to:tp];
                }
                
                sender.selected = NO;
                if (canMove) {
                    [self.moveRecords addObject:[CCMoveItem moveWitMainType:self.selectedChessman.type mainContext:@(self.selectedChessman.tag) from:fp to:tp eated:sender.type eatedContext:@(sender.tag)]];
                    
                    self.selectedChessman.frame = sender.frame;
                    self.positionInfos[@(self.selectedChessman.tag)] = @(tp);
                    
                    self.selectedChessman.selected = NO;
                    self.selectedChessman = nil;
                    [self.positionInfos removeObjectForKey:@(sender.tag)];
                    
                    [UIView animateWithDuration:animateDuration animations:^{
                        [self relayout];
                    }];
                    
                    if (self.onPlayedAction) {
                        self.onPlayedAction();
                    }
                }
            } else {
                self.selectedChessman = sender.selected ? sender : nil;
            }
        }
    }
}

- (void)boardTapAction:(UITapGestureRecognizer *)gesture
{
    if (!self.selectedChessman) {
        return;
    }
    
    CGPoint location = [gesture locationInView:gesture.view];
    
    CCPosition tp = [self mostPossiblePosition:location];
    CCPosition fp = CCDeadPosition;
    NSNumber *fpn = self.positionInfos[@(self.selectedChessman.tag)];
    if (fpn) {
        fp = [fpn intValue];
    }
    
    BOOL canMove = [CCChessUtil checkPositionValid:tp chessmen:self.selectedChessman.type];
    
    if ((self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay) && canMove) {
        // 如果是对弈模式，还需要判断棋子能否到达这个位置
        canMove = [self canMove:self.selectedChessman.type fromPosition:fp toPosition:tp];
        
        if (canMove) {
            canMove = [self checkMoveLegal:fp to:tp];
        }
    }
    
    if (canMove) {
        self.selectedChessman.frame = [self frame4ChessmanAtPosition:tp];
        self.positionInfos[@(self.selectedChessman.tag)] = @(tp);
        
        [self.moveRecords addObject:[CCMoveItem moveWitMainType:self.selectedChessman.type context:@(self.selectedChessman.tag) from:fp to:tp]];
        
        self.selectedChessman.selected = NO;
        self.selectedChessman = nil;
        
        if (self.onPlayedAction) {
            self.onPlayedAction();
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.mode == CCChessboardMode_Watch || self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay) {
        return;
    }
    
    if (self.selectedChessman) {
        NSNumber *pn = self.positionInfos[@(self.selectedChessman.tag)];
        if (pn) {
            CCPosition oldPosition = [pn intValue];
            
            [self.positionInfos removeObjectForKey:@(self.selectedChessman.tag)];
            [self.moveRecords addObject:[CCMoveItem moveWitMainType:self.selectedChessman.type context:@(self.selectedChessman.tag) from:oldPosition to:CCDeadPosition]];
        }
    }
}

#pragma mark - Public
- (void)resetChessman2Ready
{
    [self.positionInfos removeAllObjects];
    
    if (self.initialPhase.length == 0 /*|| [self.initialPhase isEqualToString:StartPhase]*/) {
        uint8_t blackPositions[16] = {
            0, 1, 2, 3, 4, 5, 6, 7, 8,
            19, 25,
            27, 29, 31, 33, 35
        };
        uint8_t *bpp = blackPositions;
        
        [self.blackChessmans enumerateObjectsUsingBlock:^(CCChessmanButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.positionInfos[@(obj.tag)] = @(bpp[idx]);
        }];
        
        uint8_t redPositions[16] = {
            89, 88, 87, 86, 85, 84, 83, 82, 81,
            70, 64,
            62, 60, 58, 56, 54
        };
        uint8_t *rpp = redPositions;
        [self.redChessmans enumerateObjectsUsingBlock:^(CCChessmanButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.positionInfos[@(obj.tag)] = @(rpp[idx]);
        }];
        
        [self relayout];
    } else {
        NSArray<CCChessmanButton *> *mans = [self.redChessmans arrayByAddingObjectsFromArray:self.blackChessmans];
        const BytePtr bytes = (BytePtr)self.initialPhase.bytes;
        for (size_t i = 0; i < self.initialPhase.length; i += 3) {
            CCChessmanType t1 = CCChessmanType_None;
            CCChessmanType t2 = CCChessmanType_None;
            CCPosition p1 = CCDeadPosition;
            CCPosition p2 = CCDeadPosition;
            
            Byte b1 = bytes[i];
            Byte b2 = bytes[i + 1];
            
            t1 = b1 >> 3;
            p1 = ((b1 & 0x07) << 4) + (b2 >> 4);
            
            if (i + 2 < self.initialPhase.length) {
                Byte b3 = bytes[i+2];
                t2 = ((b2 & 0xF) << 1) + (b3 >> 7);
                p2 = b3 & 0x7F;
            }
            
            if (p1 < 90 && p1 != CCDeadPosition) {
                CCChessmanButton *btn = nil;
                for (CCChessmanButton *b in mans) {
                    if (b.type == t1 && !self.positionInfos[@(b.tag)]) {
                        btn = b;
                        break;
                    }
                }
                
                if (btn) {
                    self.positionInfos[@(btn.tag)] = @(p1);
                } else {
                    assert("Oops! sth wrecked.");
                }
            }
            
            if (p2 < 90 && p2 != CCDeadPosition) {
                CCChessmanButton *btn = nil;
                for (CCChessmanButton *b in mans) {
                    if (b.type == t2 && !self.positionInfos[@(b.tag)]) {
                        btn = b;
                        break;
                    }
                }
                
                if (btn) {
                    self.positionInfos[@(btn.tag)] = @(p2);
                } else {
                    assert("Oops! sth wrecked.");
                }
            }
        }
    }
}

#pragma mark - Watch Mode
- (void)moveLast
{
    assert(self.mode == CCChessboardMode_Watch);
    
    if (self.currentMoveIndex > 0) {
        [self setCurrentMoveIndex:self.currentMoveIndex - 1];
    }
}

- (void)moveNext
{
    assert(self.mode == CCChessboardMode_Watch);
    
    if (self.currentMoveIndex + 1 <= (int)self.moveList.length / 4) {
        [self setCurrentMoveIndex:self.currentMoveIndex + 1];
    }
}

- (void)reset
{
    self.currentMoveIndex = 0;
    [self.moveRecords removeAllObjects];
    [self resetChessman2Ready];
}

- (void)toEnd
{
    [self setCurrentMoveIndex:(int)(self.moveList.length / 4)];
}

- (void)setCurrentMoveIndex:(int)currentMoveIndex
{
    if (currentMoveIndex > (int)self.moveList.length / 4) return;
    
    if (_currentMoveIndex != currentMoveIndex) {
        if (currentMoveIndex <= 0) {
            [self.moveRecords removeAllObjects];
            [self resetChessman2Ready];
        } else {
            if (currentMoveIndex > _currentMoveIndex) {
                // 前进了，需要补充中间的步骤
                for (int i = _currentMoveIndex + 1; i <= currentMoveIndex; i++) {
                    NSString *moveStr = [self.moveList substringWithRange:NSMakeRange(i * 4 - 4, 4)];
                    CCPosition fp = [CCChessUtil positionFromStr:[moveStr substringToIndex:2]];
                    CCPosition tp = [CCChessUtil positionFromStr:[moveStr substringFromIndex:2]];
                    
                    CCChessmanButton *man = [self chessmanAtPosition:fp];
                    CCChessmanButton *eated = [self chessmanAtPosition:tp];
                    
                    CCMoveItem *mi = [CCMoveItem moveWitMainType:man.type context:@(man.tag) from:fp to:tp];
                    if (eated) {
                        mi.eatedChessman = eated.type;
                        mi.eatedCtx = @(eated.tag);
                    }
                    [self.moveRecords addObject:mi];
                    
                    [self performMove:mi];
                }
            } else {
                // 后退了，依次执行反动作
                for (int i = _currentMoveIndex; i > currentMoveIndex; i--) {
                    CCMoveItem *mi = self.moveRecords.lastObject;
                    [self revertMove:mi];
                    [self.moveRecords removeLastObject];
                }
            }
        }
        
        _currentMoveIndex = currentMoveIndex;
        
        [UIView animateWithDuration:animateDuration animations:^{
            [self relayout];
        }];
    }
}

- (void)performMoveString:(NSString *)moveStr
{
    if (moveStr.length != 4) return;
    
    CCPosition fp = [CCChessUtil positionFromStr:[moveStr substringToIndex:2]];
    CCPosition tp = [CCChessUtil positionFromStr:[moveStr substringFromIndex:2]];
    
    CCChessmanButton *man = [self chessmanAtPosition:fp];
    CCChessmanButton *eated = [self chessmanAtPosition:tp];
    
    CCMoveItem *mi = [CCMoveItem moveWitMainType:man.type context:@(man.tag) from:fp to:tp];
    if (eated) {
        mi.eatedChessman = eated.type;
        mi.eatedCtx = @(eated.tag);
    }
    [self.moveRecords addObject:mi];
    
    [self performMove:mi];
    
    [UIView animateWithDuration:animateDuration animations:^{
        [self relayout];
    }];
}

#pragma mark - Play mode.
- (void)performFenString:(NSString *)fenMove
{
    if (fenMove.length != 4) return;
    
    DLog(@"fenMove: %@", fenMove);
    
    CCPosition fp = [CCChessUtil positionFromFen:[fenMove substringToIndex:2]];
    CCPosition tp = [CCChessUtil positionFromFen:[fenMove substringFromIndex:2]];
    
    CCChessmanButton *man = [self chessmanAtPosition:fp];
    CCChessmanButton *eated = [self chessmanAtPosition:tp];
    
    CCMoveItem *mi = [CCMoveItem moveWitMainType:man.type context:@(man.tag) from:fp to:tp];
    if (eated) {
        mi.eatedChessman = eated.type;
        mi.eatedCtx = @(eated.tag);
    }
    [self.moveRecords addObject:mi];
    
    [self performMove:mi];
    
    [UIView animateWithDuration:animateDuration animations:^{
        [self relayout];
    }];
    
    DLog(@"new position: %@", [self genPositionFen]);
}

- (NSString *)genPositionFen
{
    NSMutableString *rslt = [NSMutableString string];
    [rslt appendString:@"position fen "];
//    NSArray<NSString *> *colName = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i"];
    CCChessmanType board[10][9] = {0};
    for (CCChessmanButton *redBtn in self.redChessmans) {
        CCPosition p = [self.positionInfos[@(redBtn.tag)] intValue];
        if (CCDeadPosition == p) continue;
        
        board[CCRowOfPosition(p)][CCColOfPosition(p)] = redBtn.type;
    }
    
    for (CCChessmanButton *blackBtn in self.blackChessmans) {
        CCPosition p = [self.positionInfos[@(blackBtn.tag)] intValue];
        if (CCDeadPosition == p) continue;
        
        board[CCRowOfPosition(p)][CCColOfPosition(p)] = blackBtn.type;
    }
    
    for (int r = 0; r < 10; r++) {
        int zeroCount = 0;
        for (int c = 0; c < 9; c++) {
            if (board[r][c] != 0) {
                if (zeroCount != 0) {
                    [rslt appendFormat:@"%d", zeroCount];
                    zeroCount = 0;
                }
                
                [rslt appendString:fenType(board[r][c])];
            } else {
                zeroCount++;
            }
        }
        
        if (zeroCount != 0) {
            [rslt appendFormat:@"%d", zeroCount];
        }
        
        if (r != 9) {
            [rslt appendString:@"/"];
        }
    }
    
    int eatIdx = 0;
    for (int i = (int)self.moveRecords.count - 1; i > 0; i--) {
        if (self.moveRecords[i].eatedChessman != CCChessmanType_None) {
            eatIdx = i;
            break;
        }
    }
    
    int lastEatStep = self.currentMoveIndex - eatIdx;
    int roundIdx = self.currentMoveIndex / 2 + 1;
    if (self.currentMoveIndex % 2 == 0) {
        [rslt appendString:@" w - - "];
    } else {
        [rslt appendString:@" b - - "];
    }
    [rslt appendFormat:@"%d %d", lastEatStep, roundIdx];
    
    return rslt;
}

- (NSString *)getPhaseFenPresentation
{
    static NSString *oriFen = @"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR";
    NSMutableString *moveStr = [NSMutableString string];
    [self.moveRecords enumerateObjectsUsingBlock:^(CCMoveItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [moveStr appendFormat:@"%@ ", obj.Fen];
    }];
    return [NSString stringWithFormat:@"position fen %@ w - - 0 1 moves %@", oriFen, moveStr];
}

- (NSString *)lastMove
{
    return [self.moveRecords.lastObject Fen];
}

- (NSString *)getPrivateMoveList
{
    NSMutableString *rslt = [NSMutableString string];
    
    for (CCMoveItem *mi in self.moveRecords) {
        [rslt appendString:[CCChessUtil positionString:mi.from]];
        [rslt appendString:[CCChessUtil positionString:mi.to]];
    }
    
    return rslt;
}

- (NSString *)getFenMoveList
{
    NSMutableString *rslt = [NSMutableString string];
    
    for (CCMoveItem *mi in self.moveRecords) {
        [rslt appendString:[CCChessUtil FenFromPosition:mi.from]];
        [rslt appendString:[CCChessUtil FenFromPosition:mi.to]];
        [rslt appendString:@" "];
    }
    
    return rslt;
}
#pragma mark - Edit Mode
- (BOOL)canGoback
{
    assert(self.mode == CCChessboardMode_Edit || self.mode == CCChessboardMode_Play);
    return self.moveRecords.count > 0;
}

- (void)backOneStep
{
    assert(self.mode == CCChessboardMode_Edit || self.mode == CCChessboardMode_Play || self.mode == CCChessboardMode_SelfPlay);
    if (self.moveRecords.count == 0) {
        return;
    }
    
    CCMoveItem *lastMove = self.moveRecords.lastObject;
    [self revertMove:lastMove];
    [self.moveRecords removeLastObject];
    
    if (self.mode == CCChessboardMode_Play && isRed(lastMove.mainChessman) == self.isBlack) {
        CCMoveItem *last2Move = self.moveRecords.lastObject;
        [self revertMove:last2Move];
        [self.moveRecords removeLastObject];
    }
    
    [UIView animateWithDuration:animateDuration animations:^{
        [self relayout];
    }];
}

- (void)clearAll
{
    assert(self.mode == CCChessboardMode_Edit);
    
    [self.positionInfos removeAllObjects];
    
    [self relayout];
}

- (NSString *)phaseCheckValid
{
    NSString *errorMsg = nil;
    // TODO: 
    // 1、必须有将帅、且二者不能照面
    CCPosition jiangP = [self.positionInfos[@(BLACK_CHESSMAN_TAG_BASE + 4)] intValue];
    CCPosition shuaiP = [self.positionInfos[@(RED_CHESSMAN_TAG_BASE + 4)] intValue];
    
    if (jiangP == 0 && shuaiP == 0) {
        errorMsg = @"缺少将、帅".localized;
    } else if (jiangP == 0) {
        errorMsg = @"缺少将".localized;
    } else if (shuaiP == 0) {
        errorMsg = @"缺少帅".localized;
    } else if (CCColOfPosition(jiangP) == CCColOfPosition(shuaiP)) {
        BOOL hasSperator = NO;
        for (NSNumber *val in self.positionInfos.allValues) {
            CCPosition cp = [val intValue];
            if (cp != jiangP && cp != shuaiP && CCColOfPosition(jiangP) == CCColOfPosition(cp)) {
                hasSperator = YES;
                break;
            }
        }
        
        if (!hasSperator) {
            errorMsg = @"将、帅不能照面".localized;
        }
    }
    
    return errorMsg;
}

- (NSData *)genPhasePresentation
{
    if (self.positionInfos.count == 0) {
        return nil;
    }
    
    size_t byteCount = (size_t)ceilf(self.positionInfos.count * 2 * 0.75);
    uint8_t *presentation = malloc(sizeof(uint8_t) * byteCount);
    memset(presentation, 0, sizeof(uint8_t) * byteCount);
   
    NSArray *allKeys = [self.positionInfos allKeys];
    
    allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *key1 = (NSNumber *)obj1;
        NSNumber *key2 = (NSNumber *)obj2;
        
        NSNumber *p1 = self.positionInfos[key1];
        NSNumber *p2 = self.positionInfos[key2];
        
        return [p1 intValue] > [p2 intValue];
    }];
    
    int index = 0;
    for (int i = 0; i < allKeys.count; i += 2) {
        CCChessmanButton *btn1 = [self viewWithTag:[allKeys[i] intValue]];
        uint8_t t1 = btn1.type;
        uint8_t p1 = [self.positionInfos[allKeys[i]] intValue];
        uint8_t t2 = 2^6 - 1;
        uint8_t p2 = 2^8 - 1;
        if (i + 1 < allKeys.count) {
            CCChessmanButton *btn2 = [self viewWithTag:[allKeys[i+1] intValue]];
            t2 = btn2.type;
            p2 = [self.positionInfos[allKeys[i+1]] intValue];
        }
        
        Byte byte1 = (t1 << 3) + ((p1 & 0x70) >> 4);
        Byte byte2 = ((p1 & 0x0F) << 4) + ((t2 & 0x1E) >> 1);
        Byte byte3 = ((t2 & 0x1) << 7) + (p2 & 0x7F);
        
        *(presentation + index++) = byte1;
        *(presentation + index++) = byte2;
        if (index < byteCount) {
            *(presentation + index++) = byte3;
        }
    }
    
    NSData *data = [[NSData alloc] initWithBytes:presentation length:byteCount];
    DLog(@"data is: %@", data);
    free(presentation);
    
    return data;
}

- (void)setMode:(CCChessboardMode)mode
{
    if (_mode != mode) {
        _mode = mode;
        
        if (mode == CCChessboardMode_Edit) {
            [self.positionInfos removeAllObjects];
            [self.moveRecords removeAllObjects];
            if (self.initialPhase) {
                [self resetChessman2Ready];
            }
        } else if (mode == CCChessboardMode_Play || mode == CCChessboardMode_SelfPlay) {
            [self.moveRecords removeAllObjects];
            [self resetChessman2Ready];
        } else if (mode == CCChessboardMode_Watch) {
            [self setCurrentMoveIndex:0];
        }
        
        [self relayout];
    }
}

#pragma mark - Transform
- (void)resetTransform
{
    self.transform = CGAffineTransformIdentity;
    
    NSMutableArray *chessmans = [NSMutableArray arrayWithCapacity:32];
    [chessmans addObjectsFromArray:self.redChessmans];
    [chessmans addObjectsFromArray:self.blackChessmans];
    
    for (CCChessmanButton *btn in chessmans) {
        btn.transform = CGAffineTransformIdentity;
    }
}

- (void)up2Down
{
    NSMutableArray *chessmans = [NSMutableArray arrayWithCapacity:32];
    [chessmans addObjectsFromArray:self.redChessmans];
    [chessmans addObjectsFromArray:self.blackChessmans];
    
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity)) {
        self.transform = CGAffineTransformMakeScale(-1.0, -1.0);
        for (CCChessmanButton *btn in chessmans) {
            btn.transform = CGAffineTransformMakeScale(-1.0, -1.0);
        }
    } else {
        self.transform = CGAffineTransformIdentity;
        for (CCChessmanButton *btn in chessmans) {
            btn.transform = CGAffineTransformIdentity;
        }
    }
}

#pragma mark - Generate Image
- (UIImage *)boardImage
{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGRect cropRect = CGRectApplyAffineTransform(self.board.frame, CGAffineTransformMakeScale(scale, scale));
    CGImageRef cropedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    image = [UIImage imageWithCGImage:cropedImage];
    CGImageRelease(cropedImage);
    UIGraphicsEndImageContext();
    
    return image;
}
@end
