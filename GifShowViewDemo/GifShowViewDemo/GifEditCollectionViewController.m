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
@property(nonatomic, strong)NSIndexPath* curSelectedIndexPath;
@property(nonatomic, assign)CGFloat xMargin;
@property(nonatomic, strong)NSIndexPath* insertIndexPath;
@property(nonatomic, assign)CGSize imageSize;
@property(nonatomic, assign)GifEditType curEditType;

@end

@implementation GifEditCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat topMargin = 5.0f;

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
    
    
    UILongPressGestureRecognizer* longGesutre = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureDetected:)];
    longGesutre.delegate = self;
    [self.collectionView addGestureRecognizer:longGesutre];
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

//将新插入的图片的宽高调整到当前的图片大小
- (UIImage*)redrawImage: (UIImage*)inputImage
{
    CGFloat width = [[self.imageInfoDic objectForKey:@"width"] floatValue];
    CGFloat height = [[self.imageInfoDic objectForKey:@"height"] floatValue];
    
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    [inputImage drawInRect:CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void)undo: (id)sender
{
    NSLog(@"undo");
}

- (void)redo: (id)sender
{
    NSLog(@"redo");
}

- (void)longPressGestureDetected:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [gesture locationInView:gesture.view];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
        
        [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        if(indexPath)
        {
            [self showImageEditMenuAtPoint:touchPoint isSelected: YES];
        }
        else
        {
            //获取插入位置
            [self showImageEditMenuAtPoint:touchPoint isSelected: NO];
            
            NSIndexPath* insertIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(touchPoint.x + self.xMargin, touchPoint.y)];
            
            if (!insertIndexPath)
            {
                insertIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(2 * self.xMargin, touchPoint.y + 2 * topMargin + 1.0f + self.imageSize.height)];
            }
            //如果这个时候还没有找到indexPath 那么插入位置就是最后一个了。
            self.insertIndexPath = insertIndexPath;
        }
    }
}

- (void)showImageEditMenuAtPoint: (CGPoint)touchPoint isSelected: (BOOL)isSelected
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    if (isSelected)
    {
        UIMenuItem* changeItem = [[UIMenuItem alloc] initWithTitle:@"更换" action:@selector(changeSelectedImage:)];
        UIMenuItem* deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteSelectedImage:)];
        menu.menuItems = @[changeItem, deleteItem];
    }
    else
    {
        UIMenuItem* insertItem = [[UIMenuItem alloc] initWithTitle:@"插入" action:@selector(insertNewImage:)];
        menu.menuItems = @[insertItem];
    }
    
    [menu setTargetRect:CGRectMake(touchPoint.x, touchPoint.y, 0, 0) inView:self.collectionView];
    [self.collectionView becomeFirstResponder];
    [menu update];
    [menu setMenuVisible:YES animated:YES];

}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(insertNewImage:) ||
       action == @selector(changeSelectedImage:)||
       action == @selector(deleteSelectedImage:))
        return YES;
    else
        return NO;
}

- (void)insertNewImage: (id)sender
{
    self.curEditType = GifEditInsert;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)insertAfterSelectedImage: (UIImage*)image
{
    UIImage* newImage = [self redrawImage:image];
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    NSUInteger index = 0;
    if (self.insertIndexPath)
        index = self.insertIndexPath.row;
    else
        index = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount + 1] forKey:@"imageCount"];
    [images insertObject:newImage atIndex:index];
    
    if (self.insertIndexPath == nil)
    {
        self.insertIndexPath = [NSIndexPath indexPathForRow:imageCount inSection:0];
    }
    [self.collectionView insertItemsAtIndexPaths:@[self.insertIndexPath]];
}

#pragma mark change

- (void)changeSelectedImage: (id)sender
{
    self.curEditType = GifEditChange;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)changeAfterSelectedImage: (UIImage*)image
{
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    //将插入的图片进行重画  调整宽高。
    UIImage* newImage = [self redrawImage:image];
    NSUInteger index = self.curSelectedIndexPath.row;
    images[index] = newImage;
    [self.collectionView reloadItemsAtIndexPaths:@[self.curSelectedIndexPath]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        [picker dismissViewControllerAnimated:YES completion:^(){}];
        
        NSString* imageReferenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        PHAsset* asset = [[PHAsset fetchAssetsWithALAssetURLs:@[imageReferenceURL] options:nil] lastObject];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        __block UIImage* image = nil;
        [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             image = [UIImage imageWithData:imageData];
         }];
        if (self.curEditType == GifEditChange)
            [self changeAfterSelectedImage:image];
        else
            [self insertAfterSelectedImage:image];
    }
    else
    {
        UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"文件格式错误" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertCrl addAction:cancelAction];
        [picker dismissViewControllerAnimated:YES completion:^(){}];
        
        [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark delete

- (void)deleteSelectedImage: (id)sender
{
    [self.collectionView performBatchUpdates:^(void)
    {
        NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
        //删除对应位置图片
        NSUInteger index = self.curSelectedIndexPath.section * self.cloCount + self.curSelectedIndexPath.row;
        [images removeObjectAtIndex:index];
        NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
        [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount - 1] forKey:@"imageCount"];
        
        NSArray* deleteArr = [NSArray arrayWithObjects:self.curSelectedIndexPath, nil];
        [self.collectionView deleteItemsAtIndexPaths:deleteArr];
        self.curSelectedIndexPath = nil;
        self.curEditType = GifEditDelete;
    } completion:^(BOOL b){}];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.imageInfoDic objectForKey:@"imageCount"] intValue];
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
    
    CGSize oriImageSize = CGSizeMake([[self.imageInfoDic objectForKey:@"width"] floatValue], [[self.imageInfoDic objectForKey:@"height"] floatValue]);
    float newWidth = gifEditCellWidth;
    float newHeight = (newWidth * oriImageSize.height) / oriImageSize.width;
    imageSize = CGSizeMake(newWidth, newHeight);
    self.imageSize = imageSize;
    return imageSize;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGSize superViewSize = self.view.frame.size;;
    CGFloat lastSpace = (int)(superViewSize.width) % (int)gifEditCellWidth;
    CGFloat margin = lastSpace / (self.cloCount + 1);
    self.xMargin = margin;
    return UIEdgeInsetsMake(topMargin, margin, topMargin, margin);
}

#pragma mark <UICollectionViewDelegate>

//是否支持选中
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//选中
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GifEditCollectionViewCell* curSelCell = nil;
    if(self.curSelectedIndexPath)
        curSelCell = (GifEditCollectionViewCell*)[collectionView cellForItemAtIndexPath:self.curSelectedIndexPath];
    curSelCell.backgroundColor = [UIColor whiteColor];
    GifEditCollectionViewCell *cell = (GifEditCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell == curSelCell)
    {
        CGPoint touchPoint = cell.center;
        [self showImageEditMenuAtPoint:touchPoint isSelected:YES];
    }
    else
    {
        [cell setBackgroundColor:[UIColor yellowColor]];
        self.curSelectedIndexPath = indexPath;
    }
}

@end
