//
//  ViewController.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/21.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ViewController.h"
#import "VideoToGIFConverter.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ShowGifImageViewController.h"
#import <Photos/Photos.h>
#import "GifEditCollectionViewController.h"


@interface ViewController ()
@property(nonatomic, weak)UIButton* choiceBtn;
@property(nonatomic, weak)UIButton* createBtn;
@property(nonatomic, weak)UIButton* videoCvtBtn;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton* choiceBtn = [[UIButton alloc] init];
    self.choiceBtn = choiceBtn;
    self.choiceBtn.tag = choiceOperationTag;
    [self.choiceBtn setTitle:(NSString*)choiceImageTitle forState:UIControlStateNormal];
    self.choiceBtn.backgroundColor = [UIColor whiteColor];
    [self.choiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.choiceBtn addTarget:self action:@selector(choiceGIFImageTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.choiceBtn];
    
    UIButton* createBtn = [[UIButton alloc] init];
    self.createBtn = createBtn;
    self.createBtn.tag = createOperationTag;
    [self.createBtn setTitle:(NSString*)createGifImageTitle forState:UIControlStateNormal];
    self.createBtn.backgroundColor = [UIColor whiteColor];
    [self.createBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.createBtn addTarget:self action:@selector(createNewGifImageTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createBtn];
    
    UIButton* videoCvtBtn = [[UIButton alloc] init];
    self.videoCvtBtn = videoCvtBtn;
    self.videoCvtBtn.tag = vedioCvtOperationTag;
    [self.videoCvtBtn setTitle:(NSString*)vedioCvtGifTitle forState:UIControlStateNormal];
    self.videoCvtBtn.backgroundColor = [UIColor whiteColor];
    [self.videoCvtBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.videoCvtBtn];
    
    [self setShowBtnFrame];
}

- (void)setShowBtnFrame
{
    self.choiceBtn.frame = CGRectMake(self.view.center.x - gifOperationBtnWidth / 2, self.view.center.y - (gifOperationBtnHeight + gifOperationBtnMargin + gifOperationBtnHeight / 2), gifOperationBtnWidth, gifOperationBtnHeight);
    
    self.createBtn.frame = CGRectMake(self.view.center.x - gifOperationBtnWidth / 2, self.view.center.y - gifOperationBtnHeight / 2, gifOperationBtnWidth, gifOperationBtnHeight);
    
    self.videoCvtBtn.frame = CGRectMake(self.view.center.x - gifOperationBtnWidth / 2, self.view.center.y + (gifOperationBtnHeight / 2 + gifOperationBtnMargin), gifOperationBtnWidth, gifOperationBtnHeight);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setShowBtnFrame];
}

- (void)choiceGIFImageTarget: (UIButton*)sender
{
    //从相册中选择gif图片。
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //格式要求gif 弹提示框
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    __block NSData* gifImageData = NULL;
    if ([type isEqualToString:@"public.image"])
    {
        
        NSString* imageReferenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        PHAsset* asset = [[PHAsset fetchAssetsWithALAssetURLs:@[imageReferenceURL] options:nil] lastObject];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        
        [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             if ([dataUTI rangeOfString:@"gif"].location != NSNotFound)
             {
                 gifImageData = imageData;
             }
         }];
    }
    
    if (gifImageData)
    {
        ShowGifImageViewController* showGifViewCrl = [[ShowGifImageViewController alloc] init];
        
        CGSize showSize = CGSizeMake(self.view.frame.size.width - 2 * gifShowViewMargin, self.view.frame.size.height - 2 * gifShowViewMargin);
        CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)gifImageData, NULL);
        if (src)
        {
            NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
            CGFloat width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            CGFloat height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            showSize = compressImageWith(self.view.frame.size, CGSizeMake(width, height));
            CFRelease((__bridge CFTypeRef)(properties));
            CFRelease(src);
        }
        showGifViewCrl.showViewSize = showSize;
        showGifViewCrl.imageData = gifImageData;
        [picker dismissViewControllerAnimated:NO completion:^(){}];
        [self.navigationController pushViewController:showGifViewCrl animated:YES];
    }
    else
    {
        UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片格式错误" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertCrl addAction:cancelAction];
        [picker dismissViewControllerAnimated:YES completion:^(){}];
        
        [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];
    }
    
}

- (void)createNewGifImageTarget: (id)sender
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    GifEditCollectionViewController* gifEditViewCrl = [[GifEditCollectionViewController alloc] initWithCollectionViewLayout:layout];
    [self.navigationController pushViewController:gifEditViewCrl animated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

@end
