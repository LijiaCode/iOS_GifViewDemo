//
//  GifEditCollectionViewController.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifEditCollectionViewCell.h"

@interface GifEditCollectionViewController : UICollectionViewController<UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GifEditAddImageDelegate>

@property(nonatomic, assign)BOOL isNewGifImage;
-(instancetype)initWithImageData: (NSData*)imageData withCollectionViewLayout: (UICollectionViewLayout*)layout;
@end
