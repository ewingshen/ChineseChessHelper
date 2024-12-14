//
//  UIImage+CCUtil.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/9/11.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "UIImage+CCUtil.h"

@implementation UIImage (CCUtil)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)s
{
    CGRect rect = CGRectMake(0.0f, 0.0f, s.width, s.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
