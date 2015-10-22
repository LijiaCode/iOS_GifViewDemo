//
//  VideoToGIFConverter.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/22.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoToGIFConverter : NSObject
+ (instancetype _Nonnull)shareInstance;
- (nullable NSDate*)convertVideoToGif: (NSDictionary* _Nonnull)videoInfo;
@end
