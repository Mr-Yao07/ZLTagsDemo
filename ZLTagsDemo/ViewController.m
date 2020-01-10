//
//  ViewController.m
//  ZLTagsDemo
//
//  Created by lechech on 2020/1/9.
//  Copyright © 2020年 zl. All rights reserved.
//

#import "ViewController.h"
#import "ZLTags/ZLTagsLayout.h"
#import "UICollectonViewSubViews/TagsHeader.h"
#import "UICollectonViewSubViews/TagsFooter.h"
#import "UICollectonViewSubViews/TagsCell.h"
#import "TagTool.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ZLCollectionViewTagsLayoutDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)NSMutableArray *wishedArray;
@property (nonatomic, strong)NSMutableArray *noWishedArray;

@property (nonatomic, strong)NSMutableArray *wishedSizeArray;
@property (nonatomic, strong)NSMutableArray *noWishedSizeArray;

@end
static CGFloat DefaultHeight = 30;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZLTagsLayout *layout = [[ZLTagsLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 30;
//    layout.footerHeight = 30;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 300) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"TagsCell" bundle:nil] forCellWithReuseIdentifier:@"TagsCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"TagsHeader" bundle:nil] forSupplementaryViewOfKind:ZLCollectionElementKindSectionHeader withReuseIdentifier:@"TagsHeader"];
    [_collectionView registerNib:[UINib nibWithNibName:@"TagsFooter" bundle:nil] forSupplementaryViewOfKind:ZLCollectionElementKindSectionFooter withReuseIdentifier:@"TagsFooter"];
    
    [self initData];
}

- (void)initData {
    self.wishedSizeArray = [NSMutableArray arrayWithCapacity:self.wishedArray.count];
    self.noWishedSizeArray = [NSMutableArray arrayWithCapacity:self.noWishedArray.count];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < self.wishedArray.count; i++) {
            CGFloat width = [TagTool getTagWidth:self.wishedArray[i] Font:[UIFont systemFontOfSize:16]];
            CGSize size = CGSizeMake(width, DefaultHeight);
            [weakSelf.wishedSizeArray addObject:[NSValue valueWithCGSize:size]];
        }
        for (NSInteger i = 0; i < self.noWishedArray.count; i++) {
            CGFloat width = [TagTool getTagWidth:self.noWishedArray[i] Font:[UIFont systemFontOfSize:16]];
            CGSize size = CGSizeMake(width, DefaultHeight);
            [weakSelf.noWishedSizeArray addObject:[NSValue valueWithCGSize:size]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

#pragma mark -- UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.titleLab.text = self.wishedArray[indexPath.item];
        __weak typeof(self)weakSelf = self;
        cell.block = ^{
            [collectionView performBatchUpdates:^{
                
                [weakSelf.noWishedArray addObject:weakSelf.wishedArray[indexPath.item]];
                [weakSelf.noWishedSizeArray addObject:weakSelf.wishedSizeArray[indexPath.item]];
                
                [weakSelf.wishedArray removeObjectAtIndex:indexPath.item];
                [weakSelf.wishedSizeArray removeObjectAtIndex:indexPath.item];
                
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.item inSection:indexPath.section]]];
                [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.noWishedArray.count-1 inSection:1]]];
                
            } completion:^(BOOL finished) {
                [collectionView reloadData];
            }];
        };
        
    }else if (indexPath.section == 1){
        cell.titleLab.text = self.noWishedArray[indexPath.item];
        __weak typeof(self)weakSelf = self;
        cell.block = ^{
            [collectionView performBatchUpdates:^{
                
                [weakSelf.wishedArray addObject:weakSelf.noWishedArray[indexPath.item]];
                [weakSelf.wishedSizeArray addObject:weakSelf.noWishedSizeArray[indexPath.item]];
                
                [weakSelf.noWishedArray removeObjectAtIndex:indexPath.item];
                [weakSelf.noWishedSizeArray removeObjectAtIndex:indexPath.item];
                
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.item inSection:indexPath.section]]];
                [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.wishedArray.count-1 inSection:0]]];
                
            } completion:^(BOOL finished) {
                [collectionView reloadData];
            }];
        };
    }
    
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.wishedSizeArray.count : self.noWishedSizeArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:ZLCollectionElementKindSectionHeader]) {
        TagsHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"TagsHeader"
                                                                 forIndexPath:indexPath];
        header.titleLab.text = indexPath.section == 0 ? @"你想要的" : @"你不想要的";
        reusableView = header;
        
    } else if ([kind isEqualToString:ZLCollectionElementKindSectionFooter]) {
        TagsFooter *footer = (TagsFooter *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"TagsFooter"
                                                                 forIndexPath:indexPath];
        footer.titleLab.text = indexPath.section == 0 ? @"以上" : @"以上";
        reusableView = footer;
    }
    
    
    return reusableView;
}

#pragma mark -- ZLCollectionViewTagsLayoutDelegate

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return indexPath.section == 0 ? [self.wishedSizeArray[indexPath.item] CGSizeValue] : [self.noWishedSizeArray[indexPath.item] CGSizeValue];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section {
    return section == 0 ? UIEdgeInsetsMake(10, 0, 0, 0) : UIEdgeInsetsZero;
}



#pragma mark -- data
- (NSMutableArray *)wishedArray {
    if (!_wishedArray) {
        _wishedArray = [NSMutableArray arrayWithObjects:@"漂亮",@"可爱动人",@"活泼开朗，美丽大方",@"今天天气真的不错",@"明天晴天",@"beautiful",@"pretty and handsome", nil];
    }
    return _wishedArray;
}
- (NSMutableArray *)noWishedArray {
    if (!_noWishedArray) {
        _noWishedArray = [NSMutableArray arrayWithObjects:@"丑",@"难看",@"自私自利",@"no face",@"ugly",@"no firends", nil];
    }
    return _noWishedArray;
}
@end
