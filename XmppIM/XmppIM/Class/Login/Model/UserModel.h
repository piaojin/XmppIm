//
//  UserModel.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong)XMPPUserCoreDataStorageObject *xmppUserCoreDataStorageObject;

- (instancetype)initWithXMPPUserCoreDataStorageObject:(XMPPUserCoreDataStorageObject *)xmppUserCoreDataStorageObject;

- (instancetype)initWithJid:(XMPPJID *)jid;

@end
