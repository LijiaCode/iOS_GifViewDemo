//
//  gifImageGenerater.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/22.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "gifImageGenerater.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GifImageGenerater

+ (instancetype _Nonnull)shareInstance;
{
    static GifImageGenerater* sharedGeneraterInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGeneraterInstance = [[super allocWithZone:NULL] init];
    });
    return sharedGeneraterInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [GifImageGenerater shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [GifImageGenerater shareInstance];
}

- (NSData*)generateGIFImageWithInfo: (NSDictionary* _Nonnull)imageInfo withTmpPath: (NSString*)filePath
{
    //数据
    NSMutableArray* images = [imageInfo objectForKey:@"images"];
    //创建CFURL对象
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, false);
    
    //通过url获取图像目标
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[imageInfo objectForKey:@"delayTime"], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    
    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
    
    [dict setObject:[imageInfo objectForKey:@"loopCount"] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    //合成gif
    for (int i = 0; i < images.count; ++i)
    {
        UIImage* image = images[i];
        CGImageRef imageRef = image.CGImage;
        CGImageDestinationAddImage(destination, imageRef, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSData*  imageData = (NSData*)[NSData dataWithContentsOfURL:(__bridge NSURL *)(url)];
    CFRelease(url);
    
    return imageData;
}

- (NSMutableDictionary* _Nullable)getGifImageInfoWith: (NSData* _Nullable)imageData
{
    if (!imageData)
        return nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    NSMutableDictionary* imageInfo = nil;
    if (src)
    {
        size_t imageCount = CGImageSourceGetCount(src); //获取png图数目
       
        NSMutableArray* images = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < imageCount; ++i)
        {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(src, i, NULL);
            if (imageRef)
            {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                [images addObject:image];
                CFRelease(imageRef);
            }
        }
        
        //获取相关信息
        NSDictionary* gifProperties = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
        if(gifProperties)
        {
            NSUInteger loopCount = [[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
            //BOOL hasColorMap =  [[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap] boolValue];
            //NSString* colorMap = [gifProperties objectForKey:(NSString*)kCGImagePropertyGIFImageColorMap];
            CGFloat width = [[gifProperties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            CGFloat height = [[gifProperties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            
            NSDictionary *frameProperties = [gifProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            CGFloat delayTime = [[frameProperties valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
            
            imageInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                    images,@"images",
                                   [NSNumber numberWithInteger:imageCount],@"imageCount",
                                      [NSNumber numberWithFloat:delayTime],@"delayTime",
                                   [NSNumber numberWithInteger: loopCount],@"loopCount",
                                          [NSNumber numberWithFloat:width],@"width",
                                         [NSNumber numberWithFloat:height],@"height",
                                                                       nil];
            
            CFRelease((__bridge CFTypeRef)(gifProperties));
        }
        CFRelease(src);
    }
    return imageInfo;
}

@end
