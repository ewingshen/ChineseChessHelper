//
//  CCToolbar.h
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CCToolbarDelegate;

@interface CCToolbar : UIToolbar

- (instancetype)initWithFrame:(CGRect)frame buttonTitles:(NSArray<NSString *> *)titles delegate:(id<CCToolbarDelegate>)delegate;

@property (nonatomic, weak) id<CCToolbarDelegate> cc_delegate;
@property (nonatomic, strong, readonly) NSArray<NSString *> *titles;

- (void)updateTitle:(NSString *)newTitle forButtonAt:(NSUInteger)index;
- (void)updateEnable:(BOOL)enable forButtonAt:(NSUInteger)index;
- (void)updateSelected:(BOOL)selected forButtonAt:(NSUInteger)index;

@end

@protocol CCToolbarDelegate <NSObject>

- (void)toolbar:(CCToolbar *)tb clickButtonAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
