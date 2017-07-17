//
//  PJContentMessage.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJContentMessage.h"

@implementation PJContentMessage

- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage{
    if(self = [super init]) {
        self.content = xmppMessage.body;
        self.messageType = PJMessageContentType;
    }
    return self;
}

- (CGSize)messageContentSize{
    CGSize messageSize = [self.content boundingRectWithSize:CGSizeMake(ScreenWidth - 2 * AvatarW - 6 * AvatarM, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    super.messageContentSize = messageSize;
    return messageSize;
}

- (void)setXmppMessage:(XMPPMessage *)xmppMessage{
    super.xmppMessage = xmppMessage;
    _content = xmppMessage.body;
}

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage{
    PJContentMessage *message = [[PJContentMessage alloc] init];
    message.content = xmppMessage.body;
    message.messageType = PJMessageContentType;
    return message;
}

@end
