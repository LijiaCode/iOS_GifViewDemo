//
//  VideoPlayerView.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/11/28.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerView : UIView

@property(nonatomic, copy)NSURL* showVideoURL;

- (instancetype) initWithFrame:(CGRect)frame withURL: (NSURL*)url;

@end
