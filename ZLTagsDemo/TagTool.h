//
//  TagTool.h
//  UICollectionViewTags
//
//  Created by lechech on 2020/1/8.
//  Copyright © 2020年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TagTool : NSObject
+ (CGFloat)getWidth:(NSString *)str Font:(UIFont *)font;
+ (CGFloat)getTagWidth:(NSString *)str Font:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
