//
//  PJInputBar.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PJInputTextView,PJRecordButton,PJVoiceMessage;
//发送文本
typedef void (^SendClick)(NSString *messageContent);
//点击更多
typedef void (^MoreClick)();
//发送语音
typedef void(^SendVoice)(PJVoiceMessage *voiceMessage);
//取消语音
typedef void(^CancelVoice)();

//这边简单起见把语音的录制与发送功能也放入PJInputBar中,实际中根据需要抽出语音模块
@interface PJInputBar : UIView
//语音按钮
@property (nonatomic, strong)UIButton *voiceButton;
//更多按钮
@property (nonatomic, strong)UIButton *moreButton;
//文本输入框
@property (nonatomic, strong)PJInputTextView *inputTextView;
//录音按钮
@property (nonatomic, strong)PJRecordButton *recordButton;
//发送文本消息
@property (nonatomic, copy) SendClick sendClick;
//点击更多
@property (nonatomic, copy) MoreClick moreClick;
//发送语音
@property (nonatomic, copy) SendVoice sendVoice;
//文本消息内容
@property (nonatomic, copy) NSString *messageContent;
//当前语音模式还是文字输入模式
@property (nonatomic, assign)BOOL isVoice;

@end

//文本输入框
@interface PJInputTextView : UITextView

@end

//录音按钮
@interface PJRecordButton : UIButton

@end
