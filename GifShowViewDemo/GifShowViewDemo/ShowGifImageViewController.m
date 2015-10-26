//
//  ShowGifImageViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/23.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ShowGifImageViewController.h"
#import "ShowGifImageView.h"
#import "GifEditViewController.h"

@interface ShowGifImageViewController ()
@property(nonatomic, strong)ShowGifImageView* gifShowView;
@end

@implementation ShowGifImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(enterGIFEditModel:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: editBtn, nil]];
    
    CGRect frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    self.gifShowView = [[ShowGifImageView alloc] initWithFrame:frame withImage:self.imageData];
    self.gifShowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.gifShowView];
}

- (void)enterGIFEditModel: (id)sender
{
    GifEditViewController* gifEditViewCrl = [[GifEditViewController alloc] init];
    gifEditViewCrl.imageData = self.imageData;
    [self.navigationController pushViewController:gifEditViewCrl animated:YES];
}

@end
