//
//  TagsCell.h
//  ZLTagsDemo
//
//  Created by lechech on 2020/1/9.
//  Copyright © 2020年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^DeleteBlock)(void);
@interface TagsCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *handleBtn;
@property (copy, nonatomic) DeleteBlock block;
@end

NS_ASSUME_NONNULL_END
