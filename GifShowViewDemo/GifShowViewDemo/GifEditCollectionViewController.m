//
//  GifEditCollectionViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/27.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "GifEditCollectionViewController.h"
#import "GifImageGenerater.h"
#import "ShowGifImageViewController.h"
#import <Photos/Photos.h>
#import "GifEditNotify.h"

static const CGFloat defDelayTime = .12f;

@interface GifEditCollectionViewController ()
/*
@"images",
@"imageCount",
@"delayTime",
@"loopCount",
@"width",
@"height",
 */
@property(nonatomic, strong)NSMutableDictionary* imageInfoDic;//gif 相关信息
@property(nonatomic, assign)NSUInteger cloCount; //每列个数
@property(nonatomic, assign)CGFloat xMargin; //每列x间距
@property(nonatomic, assign)CGSize imageSize; //图片大小

@property(nonatomic, strong)NSIndexPath* curSelectedIndexPath;
@property(nonatomic, strong)NSIndexPath* insertIndexPath;
@property(nonatomic, assign)GifEditType curEditType;

@property(nonatomic, strong)NSMutableArray<GifEditNotify*>* gifEditUndoStack;
@property(nonatomic, strong)NSMutableArray<GifEditNotify*>* gifEditRedoStack;
@property(nonatomic, weak)UIBarButtonItem* undoBtn;
@property(nonatomic, weak)UIBarButtonItem* redoBtn;

@property(nonatomic, strong)NSString* recentSavePath; //gif中间文档存储位置。
@end

@implementation GifEditCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat topMargin = 5.0f;

- (instancetype)initWithImageData: (NSData*)imageData withCollectionViewLayout: (UICollectionViewLayout*)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
       [self initImageInfoWithData:imageData];
    }
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self initNewGifImageInfo];
    }
    return self;
}

- (void)initNewGifImageInfo
{
    self.isNewGifImage = YES;
    self.imageInfoDic = [[NSMutableDictionary alloc] init];
    NSMutableArray* images = [[NSMutableArray alloc] init];
    [self.imageInfoDic setObject:images forKey:@"images"];
    [self.imageInfoDic setObject:[NSNumber numberWithInt:0] forKey:@"imageCount"];
    [self.imageInfoDic setObject:[NSNumber numberWithFloat:defDelayTime] forKey:@"delayTime"];
    [self.imageInfoDic setObject:[NSNumber numberWithInt:0] forKey:@"loopCount"];
}

- (void)initImageInfoWithData: (NSData*)imageData
{
    self.imageInfoDic = [[GifImageGenerater shareInstance] getGifImageInfoWith:imageData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveGifImageToLocal:)];
    UIBarButtonItem* previewBtn = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(previewGifImage:)];
    UIBarButtonItem* undoBtn = [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(undoRedo:)];
    undoBtn.enabled = NO;
    undoBtn.tag = GifUndo;
    UIBarButtonItem* redoBtn = [[UIBarButtonItem alloc] initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(undoRedo:)];
    redoBtn.tag = GifRedo;
    redoBtn.enabled = NO;
   
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: saveBtn, previewBtn, redoBtn, undoBtn, nil]];
    self.undoBtn = undoBtn;
    self.redoBtn = redoBtn;
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(getBackChoicePictureViewController:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:backBtn, nil]];
    
    self.cloCount = (int)(self.view.frame.size.width) / (int)getGifEditCellWidth();
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView.collectionViewLayout = layout;
    self.gifEditUndoStack = [[NSMutableArray alloc] init];
    self.gifEditRedoStack = [[NSMutableArray alloc] init];
    
    
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
            __unused PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL URLWithString:self.recentSavePath]];
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
    //这个操作还挺费时间的
    NSData* imageData = [[GifImageGenerater shareInstance] generateGIFImageWithInfo:self.imageInfoDic withTmpPath:filePath];
    
    if (imageData)
    {
        self.recentSavePath = filePath;
        CGFloat width = [[self.imageInfoDic objectForKey:@"width"] floatValue];
        CGFloat height = [[self.imageInfoDic objectForKey:@"height"] floatValue];
        CGSize showSize = CGSizeMake(width, height);
        ShowGifImageViewController* showGifViewCrl = [[ShowGifImageViewController alloc] init];
        showGifViewCrl.imageData = imageData;
        showGifViewCrl.showViewSize = showSize;
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
    if (width == 0 || height == 0)
    {
        CGSize showSize = compressImageWith(self.view.frame.size, inputImage.size);
        width = showSize.width;
        height = showSize.height;
        [self.imageInfoDic setObject:[NSNumber numberWithFloat:width] forKey:@"width"];
        [self.imageInfoDic setObject:[NSNumber numberWithFloat:height] forKey:@"height"];
    }
    
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    [inputImage drawInRect:CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//只要发生一次编辑操作  之前的redo都会无效。
- (void)clearRedoStack
{
    [self.gifEditRedoStack removeAllObjects];
    self.redoBtn.enabled = YES;
}

- (void)checkUndeRedoState
{
    self.redoBtn.enabled = self.gifEditRedoStack.count > 0 ? YES : NO;
    self.undoBtn.enabled = self.gifEditUndoStack.count > 0 ? YES : NO;
}

- (void)undoRedo: (UIBarButtonItem*)sender
{
    GifEditNotify* editNotify = nil;
    if (sender.tag == GifUndo)
        editNotify = self.gifEditUndoStack.lastObject;
    else
        editNotify = self.gifEditRedoStack.lastObject;
    
    GifEditNotify* newNotify = [[GifEditNotify alloc] init];
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    switch (editNotify.editType)
    {
        case GifEditChange:
        {
            NSIndexPath* indexPath = editNotify.indexPath;
            UIImage* oldImage = images[indexPath.row];
            images[indexPath.row] = editNotify.operationImages[0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
            newNotify.editType = GifEditChange;
            [newNotify.operationImages addObject:oldImage];
            newNotify.indexPath = indexPath;
            break;
        }
        case GifEditDelete:
        {
            NSIndexPath* indexPath = editNotify.indexPath;
            NSMutableArray* operationImages = editNotify.operationImages;
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, operationImages.count)];
            [images insertObjects:operationImages atIndexes:indexes];
            NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
            [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount + operationImages.count] forKey:@"imageCount"];
            
            NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
            NSUInteger beginIndex = indexPath.row;
            for (int i = 0; i < operationImages.count; ++i)
            {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:beginIndex++ inSection:0];
                [indexPaths addObject:indexPath];
            }

            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            
            newNotify.editType = GifEditInsert;
            newNotify.operationImages = operationImages;
            newNotify.indexPath = indexPath;
            break;
        }
        case GifEditInsert:
        {
            NSIndexPath* indexPath = editNotify.indexPath;
            NSMutableArray* operationImages = editNotify.operationImages;
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, operationImages.count)];
            [images removeObjectsAtIndexes:indexes];
            NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
            [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount - operationImages.count] forKey:@"imageCount"];
            NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
            NSUInteger beginIndex = indexPath.row;
            for (int i = 0; i < operationImages.count; ++i)
            {
                NSIndexPath* indexPathTmp = [NSIndexPath indexPathForRow:beginIndex++ inSection:0];
                [indexPaths addObject:indexPathTmp];
            }
            
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            
            newNotify.editType = GifEditDelete;
            newNotify.operationImages = operationImages;
            newNotify.indexPath = indexPath;
            break;
        }
        case GifEditReverse:
        {
            NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
            images = (NSMutableArray *)[[images reverseObjectEnumerator] allObjects];
            [self.imageInfoDic setObject:images forKey:@"images"];
            [self.collectionView reloadData];
            newNotify.editType = GifEditReverse;
            break;
        }
        default:
            break;
    }
    if (sender.tag == GifUndo)
    {
        [self.gifEditUndoStack removeLastObject];
        [self.gifEditRedoStack addObject:newNotify];
    }
    else
    {
        [self.gifEditRedoStack removeLastObject];
        [self.gifEditUndoStack addObject:newNotify];
    }
    
    [self checkUndeRedoState];
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
        UIMenuItem* reverseItem = [[UIMenuItem alloc] initWithTitle:@"倒转" action:@selector(reverseImages:)];
        menu.menuItems = @[insertItem, reverseItem];
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
       action == @selector(deleteSelectedImage:) ||
       action == @selector(reverseImages:))
        return YES;
    else
        return NO;
}

- (void)reverseImages: (id)sender
{
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    images = (NSMutableArray *)[[images reverseObjectEnumerator] allObjects];
    [self.imageInfoDic setObject:images forKey:@"images"];
    [self.collectionView reloadData];
    
    [self clearRedoStack];
    GifEditNotify* editNotify = [[GifEditNotify alloc] init];
    editNotify.editType = GifEditReverse;
    
    [self.gifEditUndoStack addObject:editNotify];
    [self checkUndeRedoState];

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

- (void)insertAfterSelectedImage: (NSMutableArray*)operationImages
{
    NSMutableArray* newOperationImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < operationImages.count; ++i)
    {
        UIImage* newImage = [self redrawImage:operationImages[i]];
        if (newImage)
            [newOperationImages addObject:newImage];
    }
    
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    NSUInteger index = 0;
    if (self.insertIndexPath)
        index = self.insertIndexPath.row;
    else
        index = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount + newOperationImages.count] forKey:@"imageCount"];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, newOperationImages.count)];
    [images insertObjects:newOperationImages atIndexes:indexes];
    
    if (self.insertIndexPath == nil)
        self.insertIndexPath = [NSIndexPath indexPathForRow:imageCount inSection:0];
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    NSUInteger beginIndex = self.insertIndexPath.row;
    for (int i = 0; i < newOperationImages.count; ++i)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:beginIndex++ inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
    
    [self clearRedoStack];
    GifEditNotify* editNotify = [[GifEditNotify alloc] init];
    editNotify.editType = GifEditInsert;
    editNotify.operationImages = newOperationImages;
    editNotify.indexPath = self.insertIndexPath;
    
    [self.gifEditUndoStack addObject:editNotify];
    [self checkUndeRedoState];
}

#pragma mark change

- (void)changeSelectedImage: (id)sender
{
    self.curEditType = GifEditChange;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)changeAfterSelectedImage: (UIImage*)image
{
    NSMutableArray* images = [self.imageInfoDic objectForKey:@"images"];
    //将插入的图片进行重画  调整宽高。
    UIImage* newImage = [self redrawImage:image];
    UIImage* oldImage = images[self.curSelectedIndexPath.row];
    images[self.curSelectedIndexPath.row] = newImage;
    [self.collectionView reloadItemsAtIndexPaths:@[self.curSelectedIndexPath]];
    
    
    [self clearRedoStack];
    GifEditNotify* editNotify = [[GifEditNotify alloc] init];
    editNotify.editType = GifEditChange;
    [editNotify.operationImages addObject:oldImage];
    editNotify.indexPath = self.curSelectedIndexPath;
    
    [self.gifEditUndoStack addObject:editNotify];
    [self checkUndeRedoState];
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
        
        __block NSData* selImageData = nil;
        __block BOOL isGifImage = false;
        
        [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             selImageData = imageData;
             isGifImage = [dataUTI rangeOfString:@"gif"].location != NSNotFound;
         }];
        
        if (self.curEditType == GifEditChange)
        {
            //不管是gif还是普通图 都用UIImage就可以了。
            UIImage* image = [UIImage imageWithData:selImageData];
            [self changeAfterSelectedImage:image];
        }
        else
        {
            NSMutableArray* images = [[NSMutableArray alloc] init];
            if (isGifImage)
            {
                NSMutableDictionary* imageInfo = [[GifImageGenerater shareInstance] getGifImageInfoWith:selImageData];
                images = [imageInfo objectForKey:@"images"];
            }
            else
            {
                UIImage* image = [UIImage imageWithData:selImageData];
                [images addObject:image];
            }
            
            [self insertAfterSelectedImage:images];
        }
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
        UIImage* oldImage = images[self.curSelectedIndexPath.row];
        [images removeObjectAtIndex:self.curSelectedIndexPath.row];
        NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
        [self.imageInfoDic setObject:[NSNumber numberWithInteger:imageCount - 1] forKey:@"imageCount"];
        
        NSArray* deleteArr = [NSArray arrayWithObjects:self.curSelectedIndexPath, nil];
        [self.collectionView deleteItemsAtIndexPaths:deleteArr];
        self.curEditType = GifEditDelete;
        
        [self clearRedoStack];
        GifEditNotify* editNotify = [[GifEditNotify alloc] init];
        editNotify.editType = GifEditDelete;
        [editNotify.operationImages addObject:oldImage];
        editNotify.indexPath = self.curSelectedIndexPath;
        
        [self.gifEditUndoStack addObject:editNotify];
        [self checkUndeRedoState];
        self.curSelectedIndexPath = nil;
    } completion:^(BOOL b)
    {
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.imageInfoDic objectForKey:@"imageCount"] intValue] + (self.isNewGifImage ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    GifEditCollectionViewCell *cell = (GifEditCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (self.isNewGifImage && (imageCount == indexPath.row))
    {
        cell.isAddImageBtn = YES;
        cell.delegate = self;
    }
    else
    {
        cell.isAddImageBtn = NO;
        NSArray* images = [self.imageInfoDic objectForKey:@"images"];
        UIImage* showImage = images[indexPath.section * self.cloCount + indexPath.row];
        cell.showImage = showImage;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize imageSize = CGSizeZero;
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    if (self.isNewGifImage && imageCount == 0)
    {
        float newWidth = getGifEditCellWidth();
        imageSize = CGSizeMake(newWidth, newWidth);
    }
    else
    {
        CGSize oriImageSize = CGSizeMake([[self.imageInfoDic objectForKey:@"width"] floatValue], [[self.imageInfoDic objectForKey:@"height"] floatValue]);
        float newWidth = getGifEditCellWidth();
        float newHeight = (newWidth * oriImageSize.height) / oriImageSize.width;
        imageSize = CGSizeMake(newWidth, newHeight);
        self.imageSize = imageSize;
    }
    return imageSize;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGSize superViewSize = self.view.frame.size;;
    CGFloat lastSpace = (int)(superViewSize.width) % (int)getGifEditCellWidth();
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
        curSelCell.selected = NO;
        cell.backgroundView.backgroundColor = [UIColor yellowColor];
        self.curSelectedIndexPath = indexPath;
        cell.selected = YES;
    }
}

#pragma mark <GifEditAddImageDelegate>
- (void)addPictureToNewGifImage
{
    NSUInteger imageCount = [[self.imageInfoDic objectForKey:@"imageCount"] integerValue];
    self.insertIndexPath = [NSIndexPath indexPathForRow:imageCount inSection:0];
    [self insertNewImage:nil];
}
@end
