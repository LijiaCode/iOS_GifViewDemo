//
//  GifEditCollectionViewCell.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GifEditAddImageDelegate <NSObject>
- (void)addPictureToNewGifImage;
@end

@interface GifEditCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong)UIImage* showImage;
@property(nonatomic, assign)BOOL isAddImageBtn;
@property(nonatomic, weak)id<GifEditAddImageDelegate> delegate;
@end
