//
//  VideoToGIFConverter.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/22.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "VideoToGIFConverter.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import "GifImageGenerater.h"

@implementation VideoToGIFConverter

+ (instancetype _Nonnull)shareInstance;
{
    static VideoToGIFConverter* sharedGeneraterInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGeneraterInstance = [[super allocWithZone:NULL] init];
    });
    return sharedGeneraterInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [VideoToGIFConverter shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [VideoToGIFConverter shareInstance];
}

- (nullable NSDate*)convertVideoToGif: (NSDictionary*)videoInfo
{
    NSURL *url = [videoInfo valueForKey:@"url"];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    __block NSMutableArray* images = [[NSMutableArray alloc] init];
    
    CGFloat videoDuration = asset.duration.value / asset.duration.timescale;
    NSLog(@"duration.value = %lld, duration.timescale = %d", asset.duration.value, asset.duration.timescale);
    
    generator.maximumSize = CGSizeMake(1136, 640);
    NSError *error = nil;
    
    int curFrame = 0;
    while (curFrame < videoDuration * 30)
    {
        CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(curFrame++, 30) actualTime:NULL error:&error];
        [images addObject:(__bridge id)img];
    }
    
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentStr = [document objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *textDirectory = [documentStr stringByAppendingPathComponent:@"gif"];
    [fileManager createDirectoryAtPath:textDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [textDirectory stringByAppendingPathComponent:@"test.gif"];
    
    NSDictionary* dict = @{@"images":images};
    GifImageGenerater* instance = [GifImageGenerater shareInstance];
    NSData* lldata = [instance generateGIFImageWithInfo:dict withTmpPath:path];
    return lldata;
}
@end
