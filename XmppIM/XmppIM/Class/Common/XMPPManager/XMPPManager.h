//
//  XMPPManager.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
//引包的方式
@import XMPPFramework;
#import "UserModel.h"

typedef NS_ENUM(NSInteger,XMPPConnectType){
    XMPPLogin,//登录连接
    XMPPRegister//注册连接
};

//服务器名称
#define DoMain @"piaojindemacbook-pro.local"
#define Resource @"im.piaojin"

@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

//是否退出
@property (nonatomic, assign)BOOL isLogout;

//通信管道，输入输出流
@property(nonatomic,strong)XMPPStream *xmppStream;

//好友管理
@property(nonatomic,strong)XMPPRoster *xmppRoster;

//心跳
@property (nonatomic, strong)XMPPAutoPing *xmppAutoPing;

//自动重连
@property (nonatomic, strong)XMPPReconnect *xmppReconnect;

//好友存储
@property (nonatomic, strong)XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;

@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;

@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (nonatomic, strong) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

//当前登录的用户
@property (nonatomic, strong)UserModel *currentUser;

//添加好友(new是关键字)
@property (nonatomic, strong)UserModel *pj_newFriend;

//连接服务器的目的(登录,注册)
@property (nonatomic, assign)XMPPConnectType connectType;

//单例方法
+ (XMPPManager *)shareInstanceManager;

//登录的方法
- (void)loginWithName:(NSString *)userName password:(NSString *)password;

//注册
-(void)registerWithName:(NSString *)userName password:(NSString *)password;

//添加好友
- (void)addFriend:(UserModel *)user;

//退出登录
-(void)logout;

//设置代理和激活
- (void)setUpDelegateAndActivate;

@end
