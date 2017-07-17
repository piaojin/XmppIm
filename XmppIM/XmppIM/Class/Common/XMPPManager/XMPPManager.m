//
//  XMPPManager.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "XMPPManager.h"
#import "PJCacheManager.h"


@implementation XMPPManager

+ (XMPPManager *)shareInstanceManager{
    static XMPPManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[XMPPManager alloc] init];
    });
    return shareInstance;
}

- (instancetype)init{
    if(self = [super init]){
        [self setUpDelegateAndActivate];
    }
    return self;
}

//设置代理和激活
- (void)setUpDelegateAndActivate{
    //聊天初始化
    //1.初始化xmppStream，登录和注册的时候都会用到它
    //设置服务器地址,这里用的是本地地址（可换成公司具体地址）
    //设置端口号
    //设置代理
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //添加功能模块
    //1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
    //所有的Module模块，都要激活active
    [self.xmppAutoPing activate:self.xmppStream];
    
    //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
    //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
    //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
    
    //2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
    [self.xmppReconnect activate:self.xmppStream];
    
    //好友管理初始化
    // 3.好友模块 支持我们管理、同步、申请、删除好友
    //激活
    [self.xmppRoster activate:self.xmppStream];
    //设置代理
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
    [self.xmppMessageArchiving activate:self.xmppStream];
    
    //5、文件接收
    [self.xmppIncomingFileTransfer activate:self.xmppStream];
    [self.xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

/****登录的方法
 1.初始化一个xmppStream
 2.连接服务器（成功或者失败）
 3.成功的基础上，服务器验证（成功或者失败）
 4.成功的基础上，发送上线消息
 ****/
- (void)loginWithName:(NSString *)userName password:(NSString *)password{
    //标记连接服务器的目的
    self.connectType = XMPPLogin;
    //这里记录用户输入的密码，在登录（注册）的方法里面使用
    self.currentUser.password = password;
    self.currentUser.userName = userName;
    //  创建xmppjid（用户0,  @param NSString 用户名，域名，登录服务器的方式（苹果，安卓等）
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:DoMain resource:Resource];
    self.xmppStream.myJID = jid;
    //连接到服务器
    [self connectToServer];
}

- (void)connectToServer{
    //如果已经存在一个连接或正在连接中，需要将当前的连接断开，然后再开始新的连接
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        [self logout];
    }
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:6.0f error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

-(void)registerWithName:(NSString *)userName password:(NSString *)password{
    self.currentUser.password = password;
    self.currentUser.userName = userName;
    //标记连接服务器的目的
    self.connectType = XMPPRegister;
    //1. 创建一个jid
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:DoMain resource:@"piaojin-iphone"];
    //2.将jid绑定到xmppStream
    self.xmppStream.myJID = jid;
    //3.连接到服务器
    [self connectToServer];
}

- (void)logout{
    //表示离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //向服务器发送离线消息
    [self.xmppStream sendElement:presence];
    //断开链接
    [self.xmppStream disconnect];
    [self.xmppStream removeDelegate:self];
    self.xmppReconnect.autoReconnect = NO;
    [self.xmppReconnect deactivate];
    [self.xmppAutoPing deactivate];
    [self.xmppRoster deactivate];
    [self.xmppMessageArchiving deactivate];
    [self.xmppIncomingFileTransfer deactivate];
    
    [self.xmppReconnect removeDelegate:self];
    [self.xmppAutoPing removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    [self.xmppMessageArchiving removeDelegate:self];
    [self.xmppIncomingFileTransfer removeDelegate:self];
    [self.xmppStream removeDelegate:self];
    
    self.xmppStream = nil;
    _isLogout = YES;
    [PJCacheManager cacheData:@"" Key:UserName];
    [PJCacheManager cacheData:@"" Key:PassWord];
}

//发起上线状态给服务器
- (void)goOnline{
    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:@"我现在很忙"]];
    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"xa"]];
    
    [self.xmppStream sendElement:presence];
}

//发起下线状态给服务器
- (void)offline{
    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    //表示离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:@"离线"]];
    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"xa"]];
    
    [self.xmppStream sendElement:presence];
}

#pragma XMPPStream 代理
#pragma mark 连接服务器失败的方法
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    [SVProgressHUD showErrorWithStatus:@"连接服务器超时"];
    NSLog(@"连接服务器失败的方法，请检查网络是否正常");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    [SVProgressHUD showErrorWithStatus:@"连接服务器失败"];
    NSLog(@"didReceiveError");
}

#pragma mark 连接服务器成功的方法
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接服务器成功的方法");
    //登录
    if (self.connectType == XMPPLogin) {
        NSError *error = nil;
        //向服务器发送密码验证 //验证可能失败或者成功
        [sender authenticateWithPassword:self.currentUser.password error:&error];
        if(!error){
            self.currentUser.jid = sender.myJID;
            NSLog(@"登录成功");
        }else{
            NSLog(@"登录失败");
        }
    }
    //注册
    else{
        //向服务器发送一个密码注册（成功或者失败）
        if([sender registerWithPassword:self.currentUser.password error:nil]){
            NSLog(@"注册成功");
        }else{
            NSLog(@"注册失败");
        }
    }
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"xmppStreamDidAuthenticate登录成功");
    _isLogout = NO;
    //发起上线状态
    [self goOnline];
    //发出登录通知成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccess object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"密码不正确%@",error);
    _isLogout = YES;
    [self offline];
    //发出登录通知失败通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginFaild object:nil];
}

#pragma mark 注册成功的方法
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功的方法");
}

#pragma mark 注册失败的方法
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败执行的方法");
}

#pragma mark 添加好友
- (void)addFriend:(UserModel *)user{
    if(user){
        //这里的nickname是我对它的备注，并非他的个人资料中得nickname
        [[XMPPManager shareInstanceManager].xmppRoster addUser:user.jid withNickname:user.userName];
    }
}

#pragma mark ===== 好友模块=======
/** 收到出席订阅请求（代表对方想添加自己为好友) */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    self.pj_newFriend.jid = presence.from;
    
    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",presence.from.bare];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}

#pragma getter,setter
- (UserModel *)currentUser{
    if(!_currentUser){
        _currentUser = [[UserModel alloc] init];
    }
    return _currentUser;
}

- (UserModel *)pj_newFriend{
    if(!_pj_newFriend){
        _pj_newFriend = [[UserModel alloc] init];
    }
    return _pj_newFriend;
}

- (XMPPStream *)xmppStream{
    if(!_xmppStream){
        //聊天初始化
        //1.初始化xmppStream，登录和注册的时候都会用到它
        _xmppStream = [[XMPPStream alloc] init];
        //设置服务器地址,这里用的是本地地址（可换成公司具体地址）
        [_xmppStream setHostName:@"192.168.21.202"];
        //设置端口号
        [_xmppStream setHostPort:5222];
    }
    return _xmppStream;
}

- (XMPPAutoPing *)xmppAutoPing{
    if(!_xmppAutoPing){
        //1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
        _xmppAutoPing = [[XMPPAutoPing alloc] init];
        //所有的Module模块，都要激活active
        
        //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
        [_xmppAutoPing setPingInterval:1000];
        //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
        [_xmppAutoPing setRespondsToQueries:YES];
        //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
    }
    return _xmppAutoPing;
}

- (XMPPReconnect *)xmppReconnect{
    if(!_xmppReconnect){
        //2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
        _xmppReconnect = [[XMPPReconnect alloc] init];
        [_xmppReconnect setAutoReconnect:YES];
    }
    return _xmppReconnect;
}

- (XMPPRosterCoreDataStorage *)xmppRosterCoreDataStorage{
    if(!_xmppRosterCoreDataStorage){
        // 3.好友模块 支持我们管理、同步、申请、删除好友
        _xmppRosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    }
    return _xmppRosterCoreDataStorage;
}

- (XMPPRoster *)xmppRoster{
    if(!_xmppRoster){
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        //关闭自动同步好友列表,在需要拉取好友列表的地方调用fetchRoster方法去拉取
        [_xmppRoster setAutoFetchRoster:NO];
    }
    return _xmppRoster;
}

- (XMPPMessageArchivingCoreDataStorage *)xmppMessageArchivingCoreDataStorage{
    if(!_xmppMessageArchivingCoreDataStorage){
        //4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    }
    return _xmppMessageArchivingCoreDataStorage;
}

- (XMPPMessageArchiving *)xmppMessageArchiving{
    if(!_xmppMessageArchiving){
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    }
    return _xmppMessageArchiving;
}

- (XMPPIncomingFileTransfer *)xmppIncomingFileTransfer{
    if(!_xmppIncomingFileTransfer){
        //5、文件接收
        _xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        [_xmppIncomingFileTransfer setAutoAcceptFileTransfers:YES];
    }
    return _xmppIncomingFileTransfer;
}

@end
