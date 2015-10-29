//
//  GifEditCollectionViewFlowLayout.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifEditCollectionViewFlowLayout : UICollectionViewFlowLayout
@property(nonatomic, assign)CGSize imageSize;
@property(nonatomic, assign)CGFloat leftmargin;
@property(nonatomic, assign)NSUInteger cellCount;
@end
