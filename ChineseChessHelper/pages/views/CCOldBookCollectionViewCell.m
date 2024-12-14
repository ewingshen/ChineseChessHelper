//
//  CCOldBookCollectionViewCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2020/8/25.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCOldBookCollectionViewCell.h"
#import "UIView+CCFast.h"

#define TITLE_ORI_WIDTH (120)
#define TITLE_ORI_HEIGHT (400)
#define BG_ORI_WIDTH (500)

@interface CCOldBookCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *bookImageView;

@end

@implementation CCOldBookCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.bookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"old_book_bg"]];
    self.bookImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.bookImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.contentMode = UIViewContentModeTop;
    [self.contentView addSubview:self.titleLabel];
}

- (void)updateWithTitle:(NSString *)title
{
    NSMutableArray<NSString *> *characters = [[NSMutableArray<NSString *> alloc] init];
    for (NSUInteger idx = 0; idx < title.length; ) {
        NSRange r = [title rangeOfComposedCharacterSequenceAtIndex:idx];
        idx += r.length;
        
        NSString *character = [title substringWithRange:r];
        if (character) {
            [characters addObject:character];
        }
    }
    
    self.titleLabel.text = [characters componentsJoinedByString:@"\n"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat ratio = self.width / BG_ORI_WIDTH;
    self.titleLabel.frame = CGRectMake(50 * ratio, 50 * ratio, TITLE_ORI_WIDTH * ratio, TITLE_ORI_HEIGHT * ratio);
    self.bookImageView.frame = self.contentView.bounds;
}

@end
