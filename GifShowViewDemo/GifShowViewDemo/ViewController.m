//
//  ViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/21.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ViewController.h"
#import "ShowGifImageView.h"
#import "VideoToGIFConverter.h"

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
    
//    NSString* filePath2 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"m4v"];
//    NSURL* url2 = [[NSURL alloc] initFileURLWithPath:filePath2];
//    NSDictionary* videoInfo = @{@"url":url2};
//    [[VideoToGIFConverter shareInstance] convertVideoToGif:videoInfo];
    
    //    //
//        NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentStr = [document objectAtIndex:0];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *textDirectory = [documentStr stringByAppendingPathComponent:@"gif"];
//        [fileManager createDirectoryAtPath:textDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//        NSString *path = [textDirectory stringByAppendingPathComponent:@"test.gif"];
//    
//        NSDictionary* dict = @{@"images":images, @"filePath":path};
//        GifImageGenerater* instance = [GifImageGenerater shareInstance];
//        NSData* lldata = [instance generateGIFImageWithInfo:dict];
}


@end
