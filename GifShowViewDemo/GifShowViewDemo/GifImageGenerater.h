//
//  gifImageGenerater.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/22.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifImageGenerater : NSObject

+ (instancetype _Nonnull)shareInstance;

- (NSData* _Nonnull)generateGIFImageWithInfo: (NSDictionary* _Nonnull)imageInfo withTmpPath: (NSString* _Nonnull)filePath;

- (NSMutableDictionary* _Nullable)getGifImageInfoWith: (NSData* _Nullable)imageData;

@end
