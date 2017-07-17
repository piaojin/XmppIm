//
//  PJMessageTool.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJMessageTool.h"
#import "PJContentMessage.h"
#import "PJImageMessage.h"
#import "PJVoiceMessage.h"
#import "UserModel.h"
#import "PJCacheManager.h"

@implementation PJMessageTool

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage{
    PJMessage *message = nil;
    
    if([xmppMessage.subject isEqualToString:TextMessage]){
        //文本消息
        message = [PJContentMessage dealWithMessage:xmppMessage];
    }else if ([xmppMessage.subject isEqualToString:ImageMessage]){
        //图片消息
        message = [PJImageMessage dealWithMessage:xmppMessage];
    }else if ([xmppMessage.subject isEqualToString:VoiceMessage]){
        //语音消息
        message = [PJVoiceMessage dealWithMessage:xmppMessage];
    }else{
        //                message = [[PJMessage alloc] init];
        message = [PJContentMessage dealWithMessage:xmppMessage];
    }
    
    //消息发送方是谁(即消息显示在左边还是右边)
    if([[XMPPManager shareInstanceManager].currentUser.jid.full containsString:xmppMessage.toStr]){
        message.showMessageIn = ShowMessageInLeft;
    }else{
        message.showMessageIn = ShowMessageInRight;
    }
    
    return message;
}

//处理图片消息,即把图片缓存起来
+ (void)dealReceiveImageMessage:(PJImageMessage *)imageMessage xmppMessage:(XMPPMessage *)xmppMessage imageBlock:(void(^)(PJImageMessage *imageMessage))imageBlock{
    //取出图片base64内容
    NSXMLElement *imageBase64Node = [xmppMessage elementForName:ImageMessage];
    if(imageBase64Node){
        //图片的base64字符串转换成Data并且缓存本地
        // 取出消息的解码
        NSString *base64str = imageBase64Node.stringValue;
        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:base64str options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        //图片缓存到本地会比较耗时
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PJCacheManager cacheImage:imageData imageMessage:imageMessage];
            if(imageBlock){
                imageBlock(imageMessage);
            }
        });
    }
}

//处理语音消息,即把语音缓存起来
+ (void)dealReceiveVoiceMessage:(PJVoiceMessage *)voiceMessage xmppMessage:(XMPPMessage *)xmppMessage voiceBlock:(void(^)(PJVoiceMessage *voiceMessage))voiceBlock{
    //取出语音base64内容
    NSXMLElement *voiceBase64Node = [xmppMessage elementForName:VoiceMessage];
    if(voiceBase64Node){
        //语音的base64字符串转换成Data并且缓存本地
        // 取出消息的解码
        NSString *base64str = voiceBase64Node.stringValue;
        NSData *voiceData = [[NSData alloc]initWithBase64EncodedString:base64str options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        //语音缓存到本地会比较耗时
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PJCacheManager cacheVoice:voiceData voiceMessage:voiceMessage];
            if(voiceBlock){
                voiceBlock(voiceMessage);
            }
        });
    }
}

@end
