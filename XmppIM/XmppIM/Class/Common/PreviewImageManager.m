//
//  PreviewImageManager.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/15.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PreviewImageManager.h"

@interface PreviewImageManager ()

@property (nonatomic, strong)UIWindow *window;
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation PreviewImageManager

+ (instancetype)shareInstance{
    static PreviewImageManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[PreviewImageManager alloc] init];
    });
    return shareManager;
}

+ (void)showImage:(UIImage *)image{
    if(image){
        [PreviewImageManager shareInstance].imageView.image = image;
        [[PreviewImageManager shareInstance].window addSubview:[PreviewImageManager shareInstance].imageView];
    }
}

- (void)clickImage{
    self.imageView.hidden = YES;
    [self.imageView removeFromSuperview];
    [self setImageView:nil];
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIWindow *)window{
    if(!_window){
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

@end
