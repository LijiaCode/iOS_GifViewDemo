//
//  ViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/21.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ViewController.h"
#import "ShowGifImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"gif"];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSData* imageData = [NSData dataWithContentsOfURL:fileURL];
    
    ShowGifImageView* gifView = [[ShowGifImageView alloc] initWithFrame:self.view.frame withImage:imageData];
    [self.view addSubview:gifView];
    gifView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gifView];
}


@end
