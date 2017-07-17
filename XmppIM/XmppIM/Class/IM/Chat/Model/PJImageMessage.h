//
//  PJImageMessage.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJMessage.h"
@interface PJImageMessage : PJMessage

//图片本地地址
@property (nonatomic, copy) NSString *localUrl;
//图片服务器地址
@property (nonatomic, copy) NSString *url;
//图片名字(这边以时间加用户名)
@property (nonatomic, copy) NSString *imageName;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage;

@end
