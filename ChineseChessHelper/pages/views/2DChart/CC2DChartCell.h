//
//  CC2DChartCell.h
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/10.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CC2DEntry;

@interface CC2DChartCell : UICollectionViewCell

- (void)bind:(CC2DEntry *)entry;

@end

NS_ASSUME_NONNULL_END
