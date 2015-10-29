//
//  GifEditCollectionViewController.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifEditCollectionViewController : UICollectionViewController
-(instancetype)initWithImageData: (NSData*)imageData withCollectionViewLayout: (UICollectionViewLayout*)layout;
@end
