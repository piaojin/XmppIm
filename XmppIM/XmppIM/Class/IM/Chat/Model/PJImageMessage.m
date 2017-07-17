//
//  PJImageMessage.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJImageMessage.h"
#import "PJCacheManager.h"
#import "PJDateTool.h"

@implementation PJImageMessage

- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage{
    if(self = [super init]) {
        self.messageType = PJMessageImageType;
    }
    return self;
}

- (CGSize)messageContentSize{
    CGSize messageSize = CGSizeMake(100, 200);
    super.messageContentSize = messageSize;
    return messageSize;
}

- (void)setXmppMessage:(XMPPMessage *)xmppMessage{
    super.xmppMessage = xmppMessage;
}

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage{
    PJImageMessage *message = [[PJImageMessage alloc] init];
    message.xmppMessage = xmppMessage;
    message.messageType = PJMessageImageType;
    //取出图片名称
    NSXMLElement *imageNode = [xmppMessage elementForName:XMPPElementImageMessage];
    if(imageNode){
        //图片在本地的加载需要知道图片的名称
        NSString *imageName = imageNode.stringValue;
        message.imageName = imageName;
        message.localUrl = [PJCacheManager imageCachePath:imageName];
    }
    return message;
}

@end
