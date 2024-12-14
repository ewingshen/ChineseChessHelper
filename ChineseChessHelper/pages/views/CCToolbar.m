//
//  CCToolbar.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/7/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCToolbar.h"

#define BUTTON_TAG_BASE (0x100)

@interface CCToolbar () <UIToolbarDelegate>

@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation CCToolbar

- (instancetype)initWithFrame:(CGRect)frame buttonTitles:(NSArray<NSString *> *)titles delegate:(id<CCToolbarDelegate>)delegate
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.titles = titles;
        self.cc_delegate = delegate;
        self.delegate = self;
        [self setupViews];
        self.barStyle = UIBarStyleBlack;
        self.translucent = YES;
    }
    return self;
}

- (void)setupViews
{
    NSMutableArray *items = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    NSUInteger tagIndex = 0;
    for (NSString *title in self.titles) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
        btn.tag = BUTTON_TAG_BASE + tagIndex++;
        btn.titleLabel.font = LABEL_FONT(18);
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [items addObject:barItem];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    
    self.items = items;
}

- (void)updateTitle:(NSString *)newTitle forButtonAt:(NSUInteger)index
{
    UIButton *btn = [self viewWithTag:BUTTON_TAG_BASE + index];
    [btn setTitle:newTitle forState:UIControlStateNormal];
}

- (void)updateEnable:(BOOL)enable forButtonAt:(NSUInteger)index
{    
    UIButton *btn = [self viewWithTag:BUTTON_TAG_BASE + index];
    btn.enabled = enable;
}

- (void)updateSelected:(BOOL)selected forButtonAt:(NSUInteger)index
{
    UIButton *btn = [self viewWithTag:BUTTON_TAG_BASE + index];
    btn.selected = selected;
}

- (void)buttonAction:(UIButton *)sender
{
    if (self.cc_delegate && [self.cc_delegate respondsToSelector:@selector(toolbar:clickButtonAtIndex:)]) {
        [self.cc_delegate toolbar:self clickButtonAtIndex:sender.tag - BUTTON_TAG_BASE];
    }
}

#pragma mark - UIToolbar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionAny;
}
@end
