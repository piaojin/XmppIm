//
//  UserModel.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (instancetype)initWithXMPPUserCoreDataStorageObject:(XMPPUserCoreDataStorageObject *)xmppUserCoreDataStorageObject{
    if(self = [super init]){
        _xmppUserCoreDataStorageObject = xmppUserCoreDataStorageObject;
        _jid = xmppUserCoreDataStorageObject.jid;
        _userName = _jid.user;
    }
    return self;
}

- (instancetype)initWithJid:(XMPPJID *)jid{
    if(self = [super init]){
        _jid = jid;
        _userName = _jid.user;
    }
    return self;
}

@end
