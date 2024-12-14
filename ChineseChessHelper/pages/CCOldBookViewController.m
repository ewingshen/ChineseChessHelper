//
//  CCOldBookViewController.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/8/25.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCOldBookViewController.h"
#import "CCOldBookCollectionViewCell.h"
#import "ChessDataModel.h"
#import "CCGameSearchResultViewController.h"
#import "CCChesscore.h"

#define CELL_SPACING (16)
#define CELL_WHR (500.0f / 724.0f)

static NSString *CellIdentifier = @"cell_identifier";

@interface CCOldBookViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *container;
@property (nonatomic, strong) NSArray<CCMatch *> *books;

@end

@implementation CCOldBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"古谱学习".localized;
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - CELL_SPACING * 4) / 3.0f;
    CGFloat itemHeight = itemWidth / CELL_WHR;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumInteritemSpacing = CELL_SPACING;
    layout.minimumLineSpacing = CELL_SPACING;
    self.container = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.container.delegate = self;
    self.container.dataSource = self;
    self.container.backgroundColor = [UIColor clearColor];
    [self.container registerClass:[CCOldBookCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.container.contentInset = UIEdgeInsetsMake(0, 0, AD_HEIGHT, 0);
    [self.view addSubview:self.container];
    
    self.books = [[CCChesscore core] oldBooks];
    
    [self.container reloadData];
}

#pragma mark - UICollectionView Delegate and Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.books.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCOldBookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell updateWithTitle:[self.books[indexPath.row] name]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCGameSearchResultViewController *srvc = [[CCGameSearchResultViewController alloc] init];
    srvc.searchMatchID = [self.books[indexPath.row] matchID];
    srvc.title = [self.books[indexPath.row] name];
    srvc.needPaging = YES;
    srvc.sortByTitle = YES;
    
    [self.navigationController pushViewController:srvc animated:YES];
    
}
@end
