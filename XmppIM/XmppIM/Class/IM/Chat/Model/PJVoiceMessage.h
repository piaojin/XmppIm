//
//  PJVoiceMessage.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJMessage.h"
@interface PJVoiceMessage : PJMessage

//语音本地地址
@property (nonatomic, copy) NSString *localUrl;
//语音服务器地址
@property (nonatomic, copy) NSString *url;
//语音时长
@property (nonatomic, assign)NSTimeInterval voiceTime;
//语音名字(这边以时间加用户名)
@property (nonatomic, copy) NSString *voiceName;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage;

@end
