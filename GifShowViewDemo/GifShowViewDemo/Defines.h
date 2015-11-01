//
//  Defines.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/23.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

static const CGFloat gifOperationBtnWidth = 90.f;
static const CGFloat gifOperationBtnHeight = 40.f;
static const CGFloat gifOperationBtnMargin = 30.f;

static const CGFloat gifEditCellWidth = 200.f;
static const CGFloat sectionMargin = 10.f;


#define choiceOperationTag 0
#define createOperationTag 1
#define vedioCvtOperationTag 2

static const NSString* choiceImageTitle = @"选择图片";
static const NSString* createGifImageTitle = @"创建GIF图";
static const NSString* vedioCvtGifTitle = @"视频转GIF";

NSString* getCurGifFileName();
NSString* getCurrentTimeString();
NSString* getTmpGifPath();

typedef NS_ENUM(NSUInteger, GifEditType)
{
    GifEditDelete = 0,
    GifEditChange,
    GifEditInsert
};

#endif /* Defines_h */
