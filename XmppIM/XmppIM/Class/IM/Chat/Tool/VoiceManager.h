//
//  VoiceManager.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/15.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class PJVoiceMessage;
//语音状态
typedef NS_ENUM(NSInteger,VoiceState){
    Recording,//录音中
    RecordEnd,//录音结束
    RecordPause//录音暂停
};
//最长录音时间
#define MaxRecordTime 60.0
//最短录音时间
#define MinRecordTime 1.0

//发送语音
typedef void(^SendVoice)(PJVoiceMessage *voiceMessage);
//取消语音
typedef void(^CancelVoice)();

//语音录音管理类
@interface VoiceManager : NSObject

@property (nonatomic, strong)UIWindow *window;
//录音状态
@property (nonatomic, assign) VoiceState voiceState;
@property (nonatomic, strong)AVAudioRecorder *audioRecorder;
@property (weak, nonatomic) AVAudioSession *session;
//语音缓存路径
@property (nonatomic, copy) NSString *voiceCachePath;
//语音名字
@property (nonatomic, copy) NSString *voiceName;
//录音时长
@property (nonatomic, assign)NSTimeInterval recordTime;
//录音定时器
@property (nonatomic, strong)NSTimer *recordTimer;
//语音说话大小定时器
@property (nonatomic, strong)NSTimer *levelTimer;
//发送语音
@property (nonatomic, copy) SendVoice sendVoice;
//取消语音
@property (nonatomic, copy) CancelVoice cancelVoice;

+ (instancetype)shareInstance;

//显示录音界面
- (void)showRecorder;

//显示取消录音界面
- (void)showPauseRecorder;

//关闭录音
- (void)closeRecorder;

//开始录音
- (BOOL)startRecord;

//停止录音
- (void)stopRecord;

//取消录音
- (void)cancelRecord;

//暂停录音
- (void)pauseRecord;

//继续录音
- (void)continueRecord;

@end
