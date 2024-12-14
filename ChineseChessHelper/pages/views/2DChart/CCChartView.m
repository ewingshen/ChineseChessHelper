//
//  CCChartView.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/10.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCChartView.h"
#import "CC2DEntry.h"
#import "CC2DChartCell.h"
#import "UIView+CCFast.h"

@interface CCChartView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *cv;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CCChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.cv];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateConstraints
{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self);
    }];
    
    [self.cv mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self).inset(12);
        make.bottom.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(-4);
    }];
    
    [super updateConstraints];
}

- (void)setEntries:(NSArray<CC2DEntry *> *)entries
{
    if (_entries != entries) {
        _entries = entries;
        
        [self.cv reloadData];
    }
}

- (NSString *)titile
{
    return self.titleLabel.text;
}

- (void)setTitile:(NSString *)title
{
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UICollectionView *)cv
{
    if (!_cv) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 2;
        _cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_cv registerClass:[CC2DChartCell class] forCellWithReuseIdentifier:CC2DChartCell.cc_reuseIdentifier];
        _cv.backgroundColor = [UIColor clearColor];
        _cv.delegate = self;
        _cv.dataSource = self;
    }
    return _cv;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.entries.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CC2DChartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CC2DChartCell cc_reuseIdentifier] forIndexPath:indexPath];
    
    CC2DEntry *entry = self.entries[indexPath.row];
    [cell bind:entry];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30, collectionView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CC2DEntry *entry = self.entries[indexPath.row];
    if (entry) {
        CALL_BLOCK(self.selecteEntry, entry)
    }
}
@end
