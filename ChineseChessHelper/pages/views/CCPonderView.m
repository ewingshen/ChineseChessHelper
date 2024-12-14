//
//  CCPonderView.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/2.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCPonderView.h"
#import "UIView+CCFast.h"
#import "CCPonderCell.h"
#import "NSArray+Utils.h"
#import "CCChessUtil.h"
#import "CCAnalysisView.h"

@interface CCPonderView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<PikafishFullInfo *> *infos;
@property (nonatomic, strong) UICollectionView *cv;

@end

@implementation CCPonderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        self.infos = [NSMutableArray array];
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    UICollectionView *v = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [v registerClass:[CCPonderCell class] forCellWithReuseIdentifier:[CCPonderCell cc_reuseIdentifier]];
    v.delegate = self;
    v.dataSource = self;
    v.backgroundColor = [UIColor clearColor];
    [self addSubview:v];
    
    self.cv = v;
}

- (void)updateInfo:(PikafishFullInfo *)info
{
    if (self.infos.count == 0 && info.depth > 1) return;
    
    PikafishFullInfo *oldInfo = nil;
    for (PikafishFullInfo *item in self.infos) {
        if (item.multiPV == info.multiPV) {
            oldInfo = item;
            break;
        }
    }
    
    if (info.depth > oldInfo.depth || (info.depth == oldInfo.depth && info.selDepth > oldInfo.selDepth)) {
        
        NSString *pvMoveList = [CCChessUtil moveListFrom:info.pv];
        NSString *completeMoves = [self.moves stringByAppendingString:pvMoveList];
        
        NSArray<NSString *> *displayMoveList = [CCChessUtil translateMoveList2FriendlyWord:completeMoves withInitialPhase:self.initialPhase];
        info.startPhase = self.initialPhase;
        info.pvMoveList = completeMoves;
        info.startMoveIndex = (int)self.moves.length / 4;
        info.pvDisplayList = [displayMoveList subarrayWithRange:NSMakeRange(info.startMoveIndex, displayMoveList.count - info.startMoveIndex)];
        info.score4Display = [info displayScore:(self.moves.length / 4) % 2 == 0];
        
        [self.infos removeObject:oldInfo];
        [self.infos addObject:info];
        
        [self.infos sortUsingComparator:^NSComparisonResult(PikafishFullInfo *  _Nonnull obj1, PikafishFullInfo *  _Nonnull obj2) {
            return obj1.multiPV > obj2.multiPV;
        }];
        
        [self.cv reloadData];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cv.frame = self.bounds;
}

- (void)reset
{
    self.initialPhase = nil;
    [self.infos removeAllObjects];
}

#pragma mark - UICollectionViewDelegate & DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.infos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.width / 2 - 12, self.height - 16);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCPonderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CCPonderCell.cc_reuseIdentifier forIndexPath:indexPath];
    
    PikafishFullInfo *info = self.infos[indexPath.row];
    if (info) {
        [cell updateScore:info.score4Display moveList:info.pvDisplayList nextIsRed:((self.moves.length/4) % 2 == 0) depth:info.depth];
        CGSize bs = self.boardSize;
        weakify(cell)
        cell.playAction = ^{
            if (!weak_cell) return;
            CGPoint p = [self.window convertPoint:weak_cell.center fromView:weak_cell.superview];
            CCAnalysisView *av = [[CCAnalysisView alloc] initWithBoardSize:bs initialPhase:info.startPhase moveList:info.pvMoveList currentIndex:info.startMoveIndex popOutPosition:p];
            [av show];
        };
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PikafishFullInfo *info = self.infos[indexPath.row];
    if (info) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ponderView:didSelectPV:)]) {
            [self.delegate ponderView:self didSelectPV:info];
        }
    }
}
@end
