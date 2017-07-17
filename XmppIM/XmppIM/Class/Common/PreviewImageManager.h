//
//  PreviewImageManager.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/15.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
//超级简单的图片显示器
@interface PreviewImageManager : NSObject

+ (instancetype)shareInstance;
+ (void)showImage:(UIImage *)image;

@end
