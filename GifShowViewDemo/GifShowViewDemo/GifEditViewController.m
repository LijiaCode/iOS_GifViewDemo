//
//  GifEditViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/26.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "GifEditViewController.h"
#import "GifEditView.h"

@interface GifEditViewController ()

@end

@implementation GifEditViewController

- (void)viewDidLoad
{
    GifEditView* editView = [[GifEditView alloc] init];
    editView.backgroundColor = [UIColor whiteColor];
    editView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:editView];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveGifImageToLocal:)];
    
    UIBarButtonItem *undoBtn = [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    
    UIBarButtonItem *redoBtn = [[UIBarButtonItem alloc] initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: saveBtn, undoBtn, redoBtn, nil]];
    
    [super viewDidLoad];
}

- (void)saveGifImageToLocal: (id)sendr
{
    NSLog(@"save");
}

- (void)undo: (id)sender
{
    NSLog(@"undo");
}

- (void)redo: (id)sender
{
    NSLog(@"redo");
}

@end
