//
//  CCGameSearchResultViewController.h
//  ChineseChessHelper
//
//  Created by byte dance on 2020/7/27.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CCGame;

@interface CCGameSearchResultViewController : CCViewController

// search conditions
@property (nonatomic, strong) NSData *searchPhase;
@property (nonatomic, assign) NSInteger searchRedPlayerID;
@property (nonatomic, assign) NSInteger searchBlackPlayerID;
@property (nonatomic, assign) BOOL ignore;
@property (nonatomic, assign) NSInteger searchMatchID;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTIme;

@property (nonatomic, assign) BOOL needPaging;
@property (nonatomic, assign) BOOL sortByTitle;

/// defaults YES.
@property (nonatomic, assign) BOOL search;

@property (nonatomic, strong) NSArray<CCGame *> *game2Display;

@end

NS_ASSUME_NONNULL_END
