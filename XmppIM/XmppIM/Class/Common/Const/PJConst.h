//
//  PJConst.h
//  piaojin
//
//  Created by piaojin on 16/8/8.
//  Copyright © 2016年 X团. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 基本常量

/**
 *  通知常量
 */
//登录成功
UIKIT_EXTERN NSString * const LoginSuccess;
//登录失败
UIKIT_EXTERN NSString * const LoginFaild;
//发送添加好友请求成功
UIKIT_EXTERN NSString * const SendAddFriendSuccess;
//同步好友列表成功
UIKIT_EXTERN NSString * const SyncContactsSuccess;

/**
 *  发送消息的类型
 */
//发生文本
UIKIT_EXTERN NSString * const TextMessage;
//发生图片
UIKIT_EXTERN NSString * const ImageMessage;
//发送语音
UIKIT_EXTERN NSString * const VoiceMessage;
//发送图片的节点名字
UIKIT_EXTERN NSString * const XMPPElementImageMessage;
//发送语音的节点名字
UIKIT_EXTERN NSString * const XMPPElementVoiceMessage;

/**
 *  用户信息相关
 */
//用户名
UIKIT_EXTERN NSString * const UserName;
//密码
UIKIT_EXTERN NSString * const PassWord;
