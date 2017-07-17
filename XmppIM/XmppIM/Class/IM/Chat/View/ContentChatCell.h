//
//  ContentChatCell.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatCell.h"
@class PJContentMessage;
@interface ContentChatCell : ChatCell

@property (nonatomic, strong)PJContentMessage *contentMessage;

@end
