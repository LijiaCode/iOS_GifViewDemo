//
//  GifEditNotify.h
//  GifShowViewDemo
//
//  Created by 李佳 on 15/11/2.
//  Copyright © 2015年 LiJia. All rights reserved.
//
//undo redo相关

#import <Foundation/Foundation.h>

@interface GifEditNotify : NSObject

@property(nonatomic, strong)NSMutableArray* operationImages;
@property(nonatomic, assign)GifEditType editType;
@property(nonatomic, strong)NSIndexPath* indexPath;

@end
