//
//  GifEditCollectionViewCell.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "GifEditCollectionViewCell.h"

static const CGFloat imageMargin = 4.0f;

@interface GifEditCollectionViewCell()
@property(nonatomic, strong)UIImageView* showImageView;
@end

@implementation GifEditCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
    }
    return self;
}

- (void)initAddPictureBtn
{
    UIButton* btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(imageMargin, imageMargin, self.frame.size.width - 2 * imageMargin, self.frame.size.height - 2 * imageMargin);
    [btn setTitle:@"AddPicture" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(addNewPcitrueToGifImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)addNewPcitrueToGifImage
{
    [self.delegate addPictureToNewGifImage];
}

- (void)setIsAddImageBtn:(BOOL)isAddImageBtn
{
    if (isAddImageBtn)
        [self initAddPictureBtn];
    _isAddImageBtn = isAddImageBtn;
}

- (void)setShowImage:(UIImage *)showImage
{
    if (!self.isAddImageBtn)
    {
        self.showImageView = [[UIImageView alloc] init];
        self.showImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.showImageView];
        _showImage = showImage;
        self.showImageView.image = showImage;
        [self compressImage:getGifEditCellWidth() image:_showImage];
    }
}

- (void)compressImage:(float)width image: (UIImage*)image
{
    float orgiWidth = image.size.width;
    float orgiHeight = image.size.height;
    
    float newWidth = width;
    float newHeight = (width * orgiHeight) / orgiWidth;
    
    [self.showImageView setFrame:CGRectMake(imageMargin, imageMargin, newWidth - 2 * imageMargin, newHeight - 2 * imageMargin)];
}

@end
