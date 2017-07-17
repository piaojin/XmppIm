//
//  PJMessageTool.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJMessage.h"
@class PJImageMessage,PJVoiceMessage;
@interface PJMessageTool : NSObject

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage;
//处理图片消息,即把图片缓存起来
+ (void)dealReceiveImageMessage:(PJImageMessage *)imageMessage xmppMessage:(XMPPMessage *)xmppMessage imageBlock:(void(^)(PJImageMessage *imageMessage))imageBlock;

//处理语音消息,即把语音缓存起来
+ (void)dealReceiveVoiceMessage:(PJVoiceMessage *)voiceMessage xmppMessage:(XMPPMessage *)xmppMessage voiceBlock:(void(^)(PJVoiceMessage *voiceMessage))voiceBlock;

@end
