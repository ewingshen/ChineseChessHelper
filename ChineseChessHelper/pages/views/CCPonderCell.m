//
//  CCPonderCell.m
//  ChineseChessHelper
//
//  Created by ewing on 2024/12/4.
//  Copyright © 2024 sheehangame. All rights reserved.
//

#import "CCPonderCell.h"
#import "CCChessUtil.h"

@interface CCPonderCell ()

@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UITextView *moveView;

@end

@implementation CCPonderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scoreLabel = [[UILabel alloc] init];
        self.scoreLabel.textColor = [UIColor blackColor];
        self.scoreLabel.font = [UIFont systemFontOfSize:12];
        self.scoreLabel.numberOfLines = 2;
        [self.contentView addSubview:self.scoreLabel];
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn setImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(onPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playBtn];
        
        self.moveView = [UITextView new];
        self.moveView.font = [UIFont systemFontOfSize:16];
        self.moveView.editable = false;
        [self.contentView addSubview:self.moveView];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 8;
        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateConstraints
{
    [self.scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).inset(4);
        make.centerY.equalTo(self.playBtn);
    }];
    
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).inset(4);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(40);
    }];
    
    [self.moveView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scoreLabel.mas_bottom).offset(4);
        make.leading.trailing.bottom.equalTo(self).inset(4);
    }];
    [super updateConstraints];
}

- (void)updateScore:(NSString *)score moveList:(NSArray<NSString *> *)ml nextIsRed:(BOOL)isRed depth:(int)d
{
    self.scoreLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %d", @"评分".localized, score, @"深度", d];
    
    NSMutableString *moveList = [NSMutableString string];
    
    int movePerLine = 2;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        movePerLine = 4;
    }
    
    int moveCounter = 0;
    if (!isRed) {
        [moveList appendString:@"..............  "];
        moveCounter++;
    }
    
    for (int i = 0; i< ml.count; i++) {
        [moveList appendString:ml[i]];
        
        moveCounter ++;
        if (moveCounter == movePerLine) {
            [moveList appendString:@"\n"];
            moveCounter = 0;
        } else {
            [moveList appendString:@"  "];
        }
    }
    self.moveView.text = moveList;
}

- (void)onPlayAction:(UIButton*)sender
{
    CALL_BLOCK(self.playAction)
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.scoreLabel.text = @"思考中...".localized;
    self.moveView.text = nil;
}
@end
