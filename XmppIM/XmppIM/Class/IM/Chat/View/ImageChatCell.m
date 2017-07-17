//
//  ImageChatCell.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ImageChatCell.h"
#import "PJImageMessage.h"


@implementation ImageChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initView];
    }
    return self;
}

- (void)initView{
    _pjimageView = [[UIImageView alloc] init];
    _pjimageView.userInteractionEnabled = YES;
    [self.messageContentView addSubview:_pjimageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImage)];
    [_pjimageView addGestureRecognizer:tap];
}

- (void)setMessage:(PJMessage *)message{
    [super setMessage:message];
    _imageMessage = (PJImageMessage *)message;
    _pjimageView.frame = self.messageContentView.bounds;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *tempImage = [UIImage imageWithContentsOfFile:_imageMessage.localUrl];
        NSLog(@"%@",_imageMessage.localUrl);
        dispatch_async(dispatch_get_main_queue(), ^{
            _pjimageView.image = tempImage;
        });
    });
}

- (void)clickedImage{
    if(_clickImage){
        _clickImage(_pjimageView,_imageMessage);
    }
}

@end
