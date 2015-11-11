//
//  ShowGifImageView.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/21.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "ShowGifImageView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "GifImageGenerater.h"

@interface ShowGifImageView()
@property(nonatomic, strong)NSData* imageData;
@end

@implementation ShowGifImageView

- (instancetype)initWithFrame:(CGRect)frame withImage: (NSData*)imageData
{
    if (self = [super initWithFrame:frame])
    {
        self.imageData = imageData;
    }
    return self;
}


- (void)didMoveToSuperview
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addGifKeyframeAnimation];
    });
}

- (void)addGifKeyframeAnimation
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)self.imageData, NULL);
    NSMutableArray* delayTimes = [[NSMutableArray alloc] init];
    CGFloat totleTime = 0.0f;
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (src)
    {
        size_t imageCount = CGImageSourceGetCount(src); //获取png图数目
        images = [NSMutableArray arrayWithCapacity:imageCount];
        for (size_t i = 0; i < imageCount; i++)
        {
            CGImageRef pngImage = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, i, NULL);
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            if (i == 0)
            {
                width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
                height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            }
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFDelayTime];
            if (delayTime) //会存在frameProperties为空的情况，所以在这里加以处理。
            {
                [delayTimes addObject:delayTime];
                totleTime += [delayTime floatValue];
            }
            else
            {
                [delayTimes addObject:[NSNumber numberWithFloat:0.03]];
                totleTime += 0.03;
            }
            
            if (pngImage)
            {
                [images addObject:(__bridge id)pngImage];
                CGImageRelease(pngImage);
            }
            CFRelease((__bridge CFTypeRef)(properties));
        }
        CFRelease(src);
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    CGFloat currentTime = 0;
    NSUInteger count = images.count;
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i)
    {
        [times addObject:[NSNumber numberWithFloat:(currentTime / totleTime)]];
        currentTime += [[delayTimes objectAtIndex:i] floatValue];
        [frames addObject:[images objectAtIndex:i]];
    }
    [animation setKeyTimes:times];
    [animation setValues:frames];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = totleTime;
    animation.delegate = self;
    animation.repeatCount = INT_MAX;
    
    [self sizeToFit];
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}


@end
