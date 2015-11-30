//
//  VideoPlayerView.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/11/28.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoPlayerView

- (instancetype) initWithFrame:(CGRect)frame withURL: (NSURL*)url
{
    if (self = [self initWithFrame:frame])
    {
        self.showVideoURL = url;
    }
    return self;
}

- (void)setShowVideoURL:(NSURL *)showVideoURL
{
    _showVideoURL = showVideoURL;
}


@end
