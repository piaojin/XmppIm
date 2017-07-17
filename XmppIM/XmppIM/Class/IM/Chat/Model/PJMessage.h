//
//  PJMessage.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
//信息类型
typedef NS_ENUM(NSInteger,PJMessageType){
    PJMessageContentType,//文字信息
    PJMessageImageType,//图片信息
    PJMessageVoiceType,//语音信息
    PJMessageNotifiType//通知信息(好友请求等)
};

typedef NS_ENUM(NSInteger,ShowMessageIn){
    ShowMessageInLeft,//消息显示在左边
    ShowMessageInRight//消息显示在右边
};

static CGFloat AvatarM = 10;//头像的间距
static CGFloat AvatarW = 28;//头像的宽度
static CGFloat AvatarH = 28;//头像的高度
static CGFloat M = 10;//气泡上下左右的间距

@interface PJMessage : NSObject

@property (nonatomic, assign)PJMessageType messageType;
@property (nonatomic, copy)NSString *timestamp;
@property (nonatomic, assign)ShowMessageIn showMessageIn;
@property (nonatomic, strong)XMPPMessage *xmppMessage;
//聊天消息cell高度
@property (nonatomic, assign)CGFloat rowH;
@property (nonatomic, assign)CGSize messageContentSize;

//不同的消息类型子类需要去重写改方法
+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage;

@end
