//
//  ImageChatCell.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatCell.h"
@class PJImageMessage;
typedef void(^ClickImage)(UIImageView *pjimageView,PJImageMessage *imageMessage);
@interface ImageChatCell : ChatCell

@property (nonatomic, strong)PJImageMessage *imageMessage;
@property (nonatomic, strong)UIImageView *pjimageView;
@property (nonatomic, copy) ClickImage clickImage;

@end
