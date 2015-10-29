//
//  Defines.m
//  GifShowViewDemo
//
//  Created by 李佳 on 15/10/29.
//  Copyright © 2015年 LiJia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"


NSString* getCurGifFileName()
{
    NSString* gifDirectory = getTmpGifPath();
    NSString* fileName = [NSString stringWithFormat:@"%@.gif", getCurrentTimeString()];
    NSString *path = [gifDirectory stringByAppendingPathComponent:fileName];
    
    return path;
}

NSString* getTmpGifPath()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* tmpPath = NSTemporaryDirectory();
    NSString *gifDirectory = [tmpPath stringByAppendingPathComponent:@"gif"];
    [fileManager createDirectoryAtPath:gifDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    return gifDirectory;
}

NSString* getCurrentTimeString()
{
    NSDate*  curDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY_MM_DD_MM_SS"];
    NSString *  locationString=[dateformatter stringFromDate:curDate];
    return locationString;
}