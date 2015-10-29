//
//  ShowGifImageViewController.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/23.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowGifImageViewController : UIViewController
@property(nonatomic, strong)NSData* imageData;
@property(nonatomic, assign)BOOL isPreview; //预览和非预览的工具条不一样
@end
