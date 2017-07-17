//
//  PJContentMessage.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJMessage.h"

@interface PJContentMessage : PJMessage

//文字内容
@property (nonatomic, copy) NSString *content;
- (instancetype)initWithXMPPMessage:(XMPPMessage *)xmppMessage;

@end
