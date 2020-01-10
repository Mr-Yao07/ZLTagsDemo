//
//  ZLTagsLayout.m
//  ZLTagsDemo
//
//  Created by lechech on 2020/1/9.
//  Copyright © 2020年 zl. All rights reserved.
//

#import "ZLTagsLayout.h"
#import "tgmath.h"

NSString *const ZLCollectionElementKindSectionHeader = @"ZLCollectionElementKindSectionHeader";
NSString *const ZLCollectionElementKindSectionFooter = @"ZLCollectionElementKindSectionFooter";

@interface ZLTagsLayout ()

@property (nonatomic ,weak) id <ZLCollectionViewTagsLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) NSMutableArray *unionRects;

@property (nonatomic, strong) NSArray *keyPathArray;

@end

@implementation ZLTagsLayout
static const NSInteger unionSize = 20;

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}
- (id <ZLCollectionViewTagsLayoutDelegate> )delegate {
    return (id <ZLCollectionViewTagsLayoutDelegate> )self.collectionView.delegate;
}
- (void)commonInit {
    
    self.headersAttribute = [NSMutableDictionary dictionary];
    self.footersAttribute = [NSMutableDictionary dictionary];
    self.sectionItemAttributes = [NSMutableArray array];
    self.allItemAttributes = [NSMutableArray array];
    self.contentHeight = 0.0;
    self.unionRects = [NSMutableArray array];
    
    self.itemHorizontalSpacing = 10.0;
    self.itemVerticalSpacing = 10.0;
    self.headerHeight = 0;
    self.footerHeight = 0;
    self.headerInset = UIEdgeInsetsZero;
    self.footerInset = UIEdgeInsetsZero;
    self.sectionInset = UIEdgeInsetsZero;
    self.keyPathArray = @[NSStringFromSelector(@selector(itemHorizontalSpacing)),
                              NSStringFromSelector(@selector(itemVerticalSpacing)),
                              NSStringFromSelector(@selector(headerHeight)),
                              NSStringFromSelector(@selector(footerHeight)),
                              NSStringFromSelector(@selector(headerInset)),
                              NSStringFromSelector(@selector(footerInset)),
                              NSStringFromSelector(@selector(sectionInset))];
    for (NSString *keyPath in self.keyPathArray) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([self.keyPathArray containsObject:keyPath]) {
        [self invalidateLayout];
    }
}
- (void)prepareLayout {
    [super prepareLayout];
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.unionRects removeAllObjects];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    UICollectionViewLayoutAttributes *attributes;
    CGFloat top = 0;
    for (NSInteger section = 0; section < numberOfSections; section++) {
        
        // section-specific metrics
        CGFloat itemHorizontalSpacing = self.itemHorizontalSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:itemHorizontalSpacingForSectionAtIndex:)]) {
            itemHorizontalSpacing = [self.delegate collectionView:self.collectionView layout:self itemHorizontalSpacingForSectionAtIndex:section];
        }
        
        CGFloat itemVerticalSpacing = self.itemVerticalSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:itemVerticalSpacingForSectionAtIndex:)]) {
            itemVerticalSpacing = [self.delegate collectionView:self.collectionView layout:self itemVerticalSpacingForSectionAtIndex:section];
        }
        
        UIEdgeInsets sectionInset = self.sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        CGFloat contentWidth = self.collectionView.frame.size.width - sectionInset.left - sectionInset.right;
        
        // section header
        CGFloat headerHeight = self.headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
        }
        
        UIEdgeInsets headerInset = self.headerInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
            headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
        }
        top += headerInset.top;
        
        if (headerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZLCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left + sectionInset.left, top, contentWidth - headerInset.right, headerHeight);
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }
        top += sectionInset.top;
        
        //section items
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        CGRect markRect = CGRectZero;
        for (NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:section];
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat xOffSet;
            CGFloat yOffSet;
            CGFloat itemLeft = CGRectGetMaxX(markRect) + sectionInset.left;
            if (itemLeft + itemSize.width + itemHorizontalSpacing < contentWidth) {
                xOffSet = itemLeft;
                yOffSet = top;
            }else{
                xOffSet = sectionInset.left;
                yOffSet = top + itemVerticalSpacing + itemSize.height;
            }
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffSet, yOffSet, itemSize.width, itemSize.height);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            
            top = yOffSet;
            markRect = attributes.frame;
        }
        top = CGRectGetMaxY(markRect) + sectionInset.bottom;
        [self.sectionItemAttributes addObject:itemAttributes];
        
        // section footer
        CGFloat footerHeight = self.footerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
        }
        
        UIEdgeInsets footerInset = self.footerInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
            footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
        }
        
        top += footerInset.top;
        
        if (footerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ZLCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left + sectionInset.left, top, contentWidth - footerInset.right, footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }
        _contentHeight = top;
        
    }
    // Build union rects
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, _contentHeight);
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:ZLCollectionElementKindSectionHeader]) {
        attribute = self.headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:ZLCollectionElementKindSectionFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    return attribute;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableDictionary *cellAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplHeaderAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *supplFooterAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *decorAttrDict = [NSMutableDictionary dictionary];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            switch (attr.representedElementCategory) {
                case UICollectionElementCategorySupplementaryView:
                    if ([attr.representedElementKind isEqualToString:ZLCollectionElementKindSectionHeader]) {
                        supplHeaderAttrDict[attr.indexPath] = attr;
                    } else if ([attr.representedElementKind isEqualToString:ZLCollectionElementKindSectionFooter]) {
                        supplFooterAttrDict[attr.indexPath] = attr;
                    }
                    break;
                case UICollectionElementCategoryDecorationView:
                    decorAttrDict[attr.indexPath] = attr;
                    break;
                case UICollectionElementCategoryCell:
                    cellAttrDict[attr.indexPath] = attr;
                    break;
            }
        }
    }
    
    NSArray *result = [cellAttrDict.allValues arrayByAddingObjectsFromArray:supplHeaderAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:supplFooterAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:decorAttrDict.allValues];
    return result;
}
@end
