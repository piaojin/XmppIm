//
//  PJVoiceMessage.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJVoiceMessage.h"
#import "PJCacheManager.h"

@implementation PJVoiceMessage

- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage{
    if(self = [super init]) {
        self.messageType = PJMessageVoiceType;
    }
    return self;
}

- (CGSize)messageContentSize{
    CGSize messageSize = CGSizeMake(PJScale(14) + 3 * M, PJScale(14));
    super.messageContentSize = messageSize;
    return messageSize;
}

- (void)setXmppMessage:(XMPPMessage *)xmppMessage{
    super.xmppMessage = xmppMessage;
}

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage{
    PJVoiceMessage *message = [[PJVoiceMessage alloc] init];
    message.xmppMessage = xmppMessage;
    message.messageType = PJMessageVoiceType;
    //取出语音名称
    NSXMLElement *voiceNode = [xmppMessage elementForName:XMPPElementVoiceMessage];
    if(voiceNode){
        //语音在本地的加载需要知道语音的名称
        NSString *voiceName = voiceNode.stringValue;
        message.voiceName = voiceName;
        message.localUrl = [PJCacheManager voiceCachePath:voiceName];
    }
    return message;
}

@end
