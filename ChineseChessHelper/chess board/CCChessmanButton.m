//
//  CCChessmanButton.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/6/30.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCChessmanButton.h"
#import "UIView+CCFast.h"

@interface CCChessmanButton ()

@property (nonatomic, strong) CAShapeLayer *corner;

@end

@implementation CCChessmanButton

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.corner.hidden = !selected;
}

- (CAShapeLayer *)corner
{
    if (!_corner) {
        _corner = [CAShapeLayer layer];
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGFloat lineLen = self.width * 0.2;
        CGPoint leftTop[3] = {
            CGPointMake(0, lineLen),
            CGPointMake(0, 0),
            CGPointMake(lineLen, 0),
        };
        CGPathAddLines(path, NULL, leftTop, 3);
        
        CGPoint leftBottom[3] = {
            CGPointMake(0, self.height - lineLen),
            CGPointMake(0, self.height),
            CGPointMake(lineLen, self.height),
        };
        CGPathAddLines(path, NULL, leftBottom, 3);
        
        CGPoint rightTop[3] = {
            CGPointMake(self.width - lineLen, 0),
            CGPointMake(self.width, 0),
            CGPointMake(self.width, lineLen),
        };
        CGPathAddLines(path, NULL, rightTop, 3);
        
        CGPoint rightBottom[3] = {
            CGPointMake(self.width, self.height - lineLen),
            CGPointMake(self.width, self.height),
            CGPointMake(self.width - lineLen, self.height),
        };
        CGPathAddLines(path, NULL, rightBottom, 3);
        
        _corner.path = path;
        _corner.lineWidth = 1.5;
        _corner.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        _corner.fillColor = [UIColor clearColor].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @1;
        animation.toValue = @0;
        animation.autoreverses = YES;
        animation.repeatCount = CGFLOAT_MAX;
        animation.duration = 0.5;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_corner addAnimation:animation forKey:@"shrink"];
        
        [self.layer addSublayer:_corner];
    }
    
    return _corner;
}
@end
