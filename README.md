# ZLTagsDemo
1. 利用UICollectionView实现标签效果，可添加区头、区尾、定义每个区内容的风格
2. 借鉴https://github.com/chiahsien/CHTCollectionViewWaterfallLayout
3. 优化：对属性设置添加KVO，实现对属性改变后的重新布局；与CHTCollectionViewWaterfallLayout中set方法中重写invalidateLayout作用一致。减少代码量
