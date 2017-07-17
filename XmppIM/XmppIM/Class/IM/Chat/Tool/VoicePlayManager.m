//
//  VoicePlayManager.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/17.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "VoicePlayManager.h"
#import <AVFoundation/AVFoundation.h>
@interface VoicePlayManager ()<AVAudioPlayerDelegate>

@property (nonatomic, strong)AVAudioPlayer *audioPlayer;

@end

@implementation VoicePlayManager

- (void)dealloc{
    [self stopPlayVoice];
    [self setAudioPlayer:nil];
}

+ (instancetype)shareInstance{
    static VoicePlayManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[VoicePlayManager alloc] init];
    });
    return shareManager;
}

//开始播放语音
- (void)startPlayVoice{
    //如果有正在播放的则停止,并且播放新的语音,每次同时只能播放一个语音
    if(self.audioPlayer.isPlaying){
        [self stopPlayVoice];
    }
    
    if([self.audioPlayer prepareToPlay]){
        [self.audioPlayer play];
        self.voicePlayState = VoicePlaying;
        if(self.startPlay){
            self.startPlay();
        }
    }
}

//结束播放语音
- (void)stopPlayVoice{
    if(self.audioPlayer.isPlaying){
        [self.audioPlayer stop];
    }
    self.voicePlayState = VoicePlayStop;
    if (self.playCompletion) {
        self.playCompletion();
    }
}

#pragma mark - ******************** 完成播放时的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopPlayVoice];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
}

- (AVAudioPlayer *)audioPlayer{
    if(!_audioPlayer){
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.playUrl] error:nil];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (void)setPlayUrl:(NSString *)playUrl{
    if(![_playUrl isEqualToString:playUrl]){
        //播放地址变化说明是在播放不同的语音,这时需要更新AVAudioPlayer
        _playUrl = playUrl;
        [self setAudioPlayer:nil];
    }
}

@end
