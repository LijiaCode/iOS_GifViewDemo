//
//  ShowGifImageViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/23.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ShowGifImageViewController.h"
#import "ShowGifImageView.h"
#import "GifEditCollectionViewController.h"

@interface ShowGifImageViewController ()
@property(nonatomic, strong)ShowGifImageView* gifShowView;
@end

@implementation ShowGifImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.isPreview)
    {
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(enterGIFEditModel:)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: editBtn, nil]];
    }
    else
    {
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveGifImageToLoacl:)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: saveBtn, nil]];
    }
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:backBtn, nil]];
    
    CGRect frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    self.gifShowView = [[ShowGifImageView alloc] initWithFrame:frame withImage:self.imageData];
    self.gifShowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.gifShowView];
}

- (void)enterGIFEditModel: (id)sender
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    GifEditCollectionViewController* gifEditViewCrl = [[GifEditCollectionViewController alloc] initWithImageData:self.imageData withCollectionViewLayout:layout];
    [self.navigationController pushViewController:gifEditViewCrl animated:YES];
}

- (void)goBack: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveGifImageToLoacl: (id)sender
{
    
}

- (void)dealloc
{
    NSLog(@"ShowGifImageViewController dealloc");
}

@end
