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
        
        UIButton* btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, 100, 40, 20);
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(addGifKeyframeAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)addGifKeyframeAnimation
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)self.imageData, NULL);
    NSMutableArray* delayTimes = [[NSMutableArray alloc] init];
    CGFloat totleTime = 0.0f;
    if (src)
    {
        size_t imageCount = CGImageSourceGetCount(src); //获取png图数目
        images = [NSMutableArray arrayWithCapacity:imageCount];
        for (size_t i = 0; i < imageCount; i++)
        {
            CGImageRef pngImage = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, i, NULL);
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            [delayTimes addObject:delayTime];
            totleTime += [delayTime floatValue];
            if (pngImage)
            {
                [images addObject:(__bridge id)pngImage];
                CGImageRelease(pngImage);
            }
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
    animation.repeatCount = 2;
    
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}


@end
