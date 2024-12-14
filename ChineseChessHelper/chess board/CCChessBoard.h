//
//  CCChessBoard.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/29.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCChessboardDirection) {
    CCChessboardDirection_Auto = 0,
    CCChessboardDirection_Hor,
    CCChessboardDirection_Ver,
};

typedef NS_ENUM(NSUInteger, CCChessboardMode) {
    // 局面编辑
    CCChessboardMode_Edit,
    // 对弈
    CCChessboardMode_Play,
    CCChessboardMode_SelfPlay,
    // 打谱
    CCChessboardMode_Watch,
};

@class CCMoveItem;

@interface CCChessBoard : UIView

// 编辑局面模式
@property (nonatomic, assign) CCChessboardMode mode;

@property (nonatomic, assign) CCChessboardDirection direction;

@property (nonatomic, copy) NSData *initialPhase;
@property (nonatomic, copy) NSString *moveList;
@property (nonatomic, assign) int currentMoveIndex;

@property (nonatomic, assign) BOOL isBlack;
@property (nonatomic, strong, readonly) NSMutableArray<CCMoveItem*> *moveRecords;

@property (nonatomic, copy) void(^frameChangeAction)(void);

@property (nonatomic, copy) void(^onPlayedAction)(void);

@property (nonatomic, copy, nullable) BOOL(^checkMove)(NSString *, NSString *);

- (void)resetChessman2Ready;

// watch模式
- (void)reset;
- (void)toEnd;
- (void)moveNext;
- (void)moveLast;

// edit模式
- (BOOL)canGoback;
- (void)backOneStep;
- (void)clearAll;
- (NSData *)genPhasePresentation;

// play模式
- (void)performMoveString:(NSString *)moveStr;
- (void)performFenString:(NSString *)fenMove;
- (NSString *)getPhaseFenPresentation;
- (NSString *)genPositionFen;
- (NSString *)lastMove;
/// 获取自定义协议的着法列表. 无空格
- (NSString *)getPrivateMoveList;
/// 获取Fen格式的着法列表. 有空格
- (NSString *)getFenMoveList;

// 棋盘翻转相关的
- (void)resetTransform;
- (void)up2Down;

// 获取棋盘的图片
- (UIImage *)boardImage;
- (NSString *)phaseCheckValid;

@end

NS_ASSUME_NONNULL_END
