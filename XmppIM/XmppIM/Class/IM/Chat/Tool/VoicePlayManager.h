//
//  VoicePlayManager.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/17.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,VoicePlayState) {
    VoicePlayStop,//语音停止播放
    VoicePlaying//语音播放中
};
@class PJVoiceMessage;
typedef void (^PlayCompletion)();
typedef void (^StartPlay)();
//语音播放管理类
@interface VoicePlayManager : NSObject

//语音播放完毕
@property (nonatomic, copy) PlayCompletion playCompletion;
//开始播放
@property (nonatomic, copy) StartPlay startPlay;
//语音播放地址
@property (nonatomic, copy) NSString *playUrl;
//语音播放状态
@property (nonatomic, assign)VoicePlayState voicePlayState;

+ (instancetype)shareInstance;

//开始播放语音
- (void)startPlayVoice;

//结束播放语音
- (void)stopPlayVoice;

@end
