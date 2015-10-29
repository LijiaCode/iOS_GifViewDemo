//
//  GifEditCollectionViewCell.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "GifEditCollectionViewCell.h"

@interface GifEditCollectionViewCell()
@property(nonatomic, strong)UIImageView* showImageView;
@end

@implementation GifEditCollectionViewCell
- (instancetype)init
{
    if (self = [super init])
    {
        self.showImageView = [[UIImageView alloc] init];
        self.showImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.showImageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.showImageView = [[UIImageView alloc] init];
        self.showImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.showImageView];
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}


- (void)setShowImage:(UIImage *)showImage
{
    _showImage = showImage;
    self.showImageView.image = showImage;
    [self compressImage:gifEditCellWidth image:_showImage];
}

- (void)compressImage:(float)width image: (UIImage*)image
{
    float orgiWidth = image.size.width;
    float orgiHeight = image.size.height;
    
    float newWidth = width;
    float newHeight = (width * orgiHeight) / orgiWidth;
    
    [self.showImageView setFrame:CGRectMake(0, 0, newWidth, newHeight)];
}

@end
