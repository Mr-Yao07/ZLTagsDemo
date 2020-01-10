//
//  TagsCell.m
//  ZLTagsDemo
//
//  Created by lechech on 2020/1/9.
//  Copyright © 2020年 zl. All rights reserved.
//

#import "TagsCell.h"

@implementation TagsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height/2;
}
- (IBAction)handleBtnClick:(id)sender {
    if (self.block) {
        self.block();
    }
}

@end
