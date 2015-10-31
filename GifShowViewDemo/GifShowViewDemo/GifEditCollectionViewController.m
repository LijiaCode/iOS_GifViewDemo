//
//  GifEditCollectionViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "GifEditCollectionViewController.h"
#import "GifEditCollectionViewFlowLayout.h"
#import "GifImageGenerater.h"
#import "GifEditCollectionViewCell.h"
#import "ShowGifImageViewController.h"
#import <Photos/Photos.h>


@interface GifEditCollectionViewController ()

@property(nonatomic, strong)NSMutableDictionary* imageInfoDic;
@property(nonatomic, assign)NSUInteger cloCount;
@property(nonatomic, strong)NSString* recentSavePath;

@end

@implementation GifEditCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

-(instancetype)initWithImageData: (NSData*)imageData withCollectionViewLayout: (UICollectionViewLayout*)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
       [self initWithData:imageData];
    }
    return self;
}

- (void)initWithData: (NSData*)imageData
{
    self.imageInfoDic = [[GifImageGenerater shareInstance] getGifImageInfoWith:imageData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveGifImageToLocal:)];
    UIBarButtonItem *previewBtn = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(previewGifImage:)];
    UIBarButtonItem *undoBtn = [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    UIBarButtonItem *redoBtn = [[UIBarButtonItem alloc] initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: saveBtn, previewBtn, undoBtn, redoBtn, nil]];
    
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(getBackChoicePictureViewController:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:backBtn, nil]];
    
    self.cloCount = (int)(self.view.frame.size.width) / (int)gifEditCellWidth;
    
    GifEditCollectionViewFlowLayout* layout = [[GifEditCollectionViewFlowLayout alloc] init];
    self.collectionView.collectionViewLayout = layout;

    [self.collectionView registerClass:[GifEditCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)getBackChoicePictureViewController: (id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)saveGifImageToLocal: (id)sendr
{
    NSString* filePath = getCurGifFileName();
    NSData* imageData = [[GifImageGenerater shareInstance] generateGIFImageWithInfo:self.imageInfoDic withTmpPath:filePath];
    
    if (imageData)
    {
        self.recentSavePath = filePath;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // Request creating an asset from the image.
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL URLWithString:self.recentSavePath]];
        } completionHandler:^(BOOL success, NSError *error) {
            UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertCrl addAction:cancelAction];
            
            [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];

        }];
    }
    else
    {
        UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片生成失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertCrl addAction:cancelAction];
        
        [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];
    }
}

- (void)previewGifImage: (id)sender
{
    NSString* filePath = getCurGifFileName();
    NSData* imageData = [[GifImageGenerater shareInstance] generateGIFImageWithInfo:self.imageInfoDic withTmpPath:filePath];
    
    if (imageData)
    {
        self.recentSavePath = filePath;
        ShowGifImageViewController* showGifViewCrl = [[ShowGifImageViewController alloc] init];
        showGifViewCrl.imageData = imageData;
        showGifViewCrl.isPreview = YES;
        showGifViewCrl.recentSavePath = filePath;
        [self.navigationController pushViewController:showGifViewCrl animated:YES];
    }
    else
    {
        UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片生成失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertCrl addAction:cancelAction];
        
        [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];
    }
}

- (void)undo: (id)sender
{
    NSLog(@"undo");
}

- (void)redo: (id)sender
{
    NSLog(@"redo");
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] intValue];
    CGFloat value = imageCount * 1.0 / self.cloCount;
    NSUInteger result = ceil(value);
    return result;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] intValue];
    NSUInteger value = ((imageCount - self.cloCount * section) > self.cloCount) ? self.cloCount : imageCount - self.cloCount * section;
    return value;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GifEditCollectionViewCell *cell = (GifEditCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSArray* images = [self.imageInfoDic objectForKey:@"images"];
    UIImage* showImage = images[indexPath.section * self.cloCount + indexPath.row];
    cell.showImage = showImage;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize imageSize = CGSizeZero;
    
    CGSize oriImageSize = CGSizeMake([[self.imageInfoDic objectForKey:@"width"] floatValue], [[self.imageInfoDic objectForKey:@"width"] floatValue]);
    float newWidth = gifEditCellWidth;
    float newHeight = (newWidth * oriImageSize.height) / oriImageSize.width;
    imageSize = CGSizeMake(newWidth, newHeight);
    
    return imageSize;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGSize superViewSize = self.view.frame.size;;
    CGFloat lastSpace = (int)(superViewSize.width) % (int)gifEditCellWidth;
    CGFloat margin = lastSpace / (self.cloCount + 1);
    GifEditCollectionViewFlowLayout* layout = (GifEditCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = margin;
    layout.leftmargin = margin;
    return UIEdgeInsetsMake(0, margin, 0, margin);
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)dealloc
{
    NSLog(@"GifEditCollectionViewController dealloc");
}

@end
