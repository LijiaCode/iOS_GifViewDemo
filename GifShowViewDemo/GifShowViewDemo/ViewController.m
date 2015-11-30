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
#import "VideoPlayerViewController.h"


@interface ViewController ()
@property(nonatomic, weak)UIButton* choiceBtn;
@property(nonatomic, weak)UIButton* createBtn;
@property(nonatomic, weak)UIButton* videoCvtBtn;
@property(nonatomic, assign)BOOL isVedioModel;
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
    [self.videoCvtBtn addTarget:self action:@selector(selectVedioOrCamera:) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.isVedioModel = NO;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)imageModeDidFinishPickingMedia:(UIImagePickerController *)picker withInfo: (NSDictionary<NSString *,id> *)info
{
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

- (void)videoModeDidFinishPickingMedia:(UIImagePickerController *)picker withInfo: (NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    NSURL* mediaUrl = nil;
    if([type isEqualToString:(NSString *)kUTTypeMovie])
    {
        mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    }
    
    if (mediaUrl)
    {
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // Create a change request from the asset to be modified.
            __unused PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:mediaUrl];
        } completionHandler:^(BOOL success, NSError *error) {
            NSLog(@"Finished updating asset. %@", (success ? @"Success." : error));
        }];
        
        VideoPlayerViewController* videoPlayerCrl = [[VideoPlayerViewController alloc] init];
        videoPlayerCrl.videoURL = mediaUrl;
        [picker dismissViewControllerAnimated:YES completion:^(){}];
        [self.navigationController pushViewController:videoPlayerCrl animated:YES];
    }
    else
    {
        UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"格式错误" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertCrl addAction:cancelAction];
        [picker dismissViewControllerAnimated:YES completion:^(){}];
        
        [self.navigationController presentViewController:alertCrl animated:YES completion:^(){}];

    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //格式要求gif 弹提示框
    if (self.isVedioModel)
        [self videoModeDidFinishPickingMedia:picker withInfo:info];
    else
        [self imageModeDidFinishPickingMedia:picker withInfo:info];
}

- (void)createNewGifImageTarget: (id)sender
{
    self.isVedioModel = NO;
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    GifEditCollectionViewController* gifEditViewCrl = [[GifEditCollectionViewController alloc] initWithCollectionViewLayout:layout];
    [self.navigationController pushViewController:gifEditViewCrl animated:YES];
}

- (void)selectVedioOrCamera: (id)sender
{
    self.isVedioModel = YES;
    UIAlertControllerStyle style = isPhone() ? UIAlertControllerStyleActionSheet :UIAlertControllerStyleAlert;
    UIAlertController* alertCrl = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:style];
    UIAlertAction* cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* photoLibrary = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [self showVideoImagePickerController:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    UIAlertAction* camera = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
        [self showVideoImagePickerController:UIImagePickerControllerSourceTypeCamera];
    }];
    
    [alertCrl addAction:photoLibrary];
    [alertCrl addAction:camera];
    [alertCrl addAction:cancle];
    
    [self presentViewController:alertCrl animated:YES completion:nil];
}

- (void)showVideoImagePickerController: (UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString*)kUTTypeVideo];
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }
   
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self.navigationController presentViewController: picker animated:YES completion:^(){}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.isVedioModel = NO;
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

@end
