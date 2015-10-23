//
//  ShowGifImageViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/23.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ShowGifImageViewController.h"
#import "ShowGifImageView.h"

@interface ShowGifImageViewController ()
@property(nonatomic, strong)ShowGifImageView* gifShowView;
@end

@implementation ShowGifImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gifShowView = [[ShowGifImageView alloc] initWithFrame:self.view.frame withImage:self.imageData];
    self.gifShowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.gifShowView];
}

@end
