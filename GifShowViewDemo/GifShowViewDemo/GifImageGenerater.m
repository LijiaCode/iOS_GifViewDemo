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

- (NSDate* _Nullable)generateGIFImageWithInfo: (NSDictionary* _Nonnull)imageInfo
{
    //数据
    NSMutableArray* images = [imageInfo objectForKey:@"images"];
    NSString* filePath = [imageInfo objectForKey:@"filePath"];
    //创建CFURL对象
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, false);
    
    //通过url获取图像目标
    CGImageDestinationRef destination;
    destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.03], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    
    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
    
    [dict setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    //合成gif
    for (int i = 0; i < images.count; ++i)
    {
        CGImageRef image = (__bridge CGImageRef)images[i];
        CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSDate*  imageData = (NSDate*)[NSData dataWithContentsOfURL:(__bridge NSURL *)(url)];
    CFRelease(url);
    
    return imageData;
}

- (NSDictionary*)getGifImageInfoWith: (NSData*)imageData
{
    if (!imageData)
        return nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    
    
    if (src)
    {
        NSDictionary *gifProperties = (__bridge NSDictionary *)CGImageSourceCopyProperties(src, NULL);
        if(gifProperties)
        {
            //由GfiImage的基本数据获取gif数据
            NSDictionary *gifDictionary = [gifProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
            //播放次数
            
            NSUInteger loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
            //获取gif的帧数
            NSMutableArray* images = [[NSMutableArray alloc] init];
            NSMutableArray* delayTimes = [[NSMutableArray alloc] init];
            BOOL hasColorMap =  [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap] boolValue];
            NSString* colorMap = [gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFImageColorMap];
            CGFloat width = [[gifProperties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            CGFloat height = [[gifProperties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            
            NSUInteger frameCount = CGImageSourceGetCount(src);
            
            for (NSUInteger i = 0; i < frameCount; i++)
            {
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, (size_t) i, NULL);
                if (img)
                {
                    UIImage *frameImage = [UIImage imageWithCGImage:img];
                    [images addObject:frameImage];
                   
                    NSDictionary *frameProperties = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(src, (size_t) i, NULL);
                    if (frameProperties)
                    {
                        NSDictionary *frameDictionary = [frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
                        [delayTimes addObject:[frameDictionary objectForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
                    }
                    CGImageRelease(img);
                }
            }
            CFRelease(src);
            
            return @{@"images":images, @"delayTimes":delayTimes,
                     @"loopCount":[NSNumber numberWithInteger: loopCount],
                     @"hasColorMap":delayTimes,
                     @"hasColorMap":[NSNumber numberWithBool:hasColorMap],
                     @"colorMap":colorMap, @"width":[NSNumber numberWithFloat:width],
                     @"height":[NSNumber numberWithFloat:height]};
        }
    }
    return nil;
}

@end
