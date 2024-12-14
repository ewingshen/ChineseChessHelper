//
//  UIView+CCFast.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/30.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "UIView+CCFast.h"
#import "NSArray+Utils.h"
#import "AppDelegate.h"

@implementation UIView (CCFast)

- (CGFloat)height
{
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height
{
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (CGFloat)width
{
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width
{
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (CGFloat)top
{
    return CGRectGetMinY(self.frame);
}

- (void)setTop:(CGFloat)top
{
    CGRect f = self.frame;
    f.origin.y = top;
    self.frame = f;
}

- (CGFloat)left
{
    return CGRectGetMinX(self.frame);
}

- (void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect f = self.frame;
    f.size.height = bottom - f.origin.y;
    self.frame = f;
}

- (CGFloat)right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setRight:(CGFloat)right
{
    CGRect f = self.frame;
    f.size.width = right - f.origin.x;
    self.frame = f;
}

- (CGSize)size 
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect f = self.frame;
    f.size = size;
    self.frame = f;
}

- (void)relayout
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

+ (UIWindow *)keyWindow
{
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
}
@end

@implementation UITableViewCell(CCUtils)

+ (NSString *)cc_reuseIdentifier 
{
    return NSStringFromClass(self);
}

@end

@implementation UICollectionViewCell (CCUtils)

+ (NSString *)cc_reuseIdentifier
{
    return NSStringFromClass(self);
}

@end
