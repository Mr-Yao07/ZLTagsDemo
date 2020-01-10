//
//  TagTool.m
//  UICollectionViewTags
//
//  Created by lechech on 2020/1/8.
//  Copyright © 2020年 zl. All rights reserved.
//

#import "TagTool.h"

static CGFloat reservedWidth = 20 + 30;// 文字左右宽度+5，预留按扭宽度
@implementation TagTool
+ (CGFloat)getWidth:(NSString *)str Font:(UIFont *)font {
    CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.width;
}
+ (CGFloat)getTagWidth:(NSString *)str Font:(UIFont *)font {
    CGFloat strWidth = [self getWidth:str Font:font];
    return (strWidth + reservedWidth);
}
@end
