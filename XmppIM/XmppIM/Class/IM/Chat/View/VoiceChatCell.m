//
//  VoiceChatCell.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "VoiceChatCell.h"
#import "PJVoiceMessage.h"
#import "VoicePlayManager.h"

@interface VoiceChatCell ()

@property (nonatomic, strong)UIImageView *voiceImageView;
@property (nonatomic, copy)NSArray *voiceAnimImages;
@property (nonatomic, strong)UIView *voiceBgView;

@end

@implementation VoiceChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initView];
    }
    return self;
}

- (void)initView{
    _voiceBgView = [[UIView alloc] init];
    [self.messageContentView addSubview:_voiceBgView];
    
    _voiceImageView = [[UIImageView alloc] init];
    [_voiceBgView addSubview:_voiceImageView];
    
    WeakSelf
    [VoicePlayManager shareInstance].playCompletion = ^{
        [weakSelf stopPlayVoice];
    };
    
    [VoicePlayManager shareInstance].startPlay = ^{
        [weakSelf startPlayVoice];
    };
}

- (void)setMessage:(PJMessage *)message{
    //一定先要去调用父类的,去做一些初始化工作
    [super setMessage:message];
    _voiceMessage = (PJVoiceMessage *)message;
    CGFloat voiceImageViewW = PJScale(14);
    CGFloat voiceImageViewH = voiceImageViewW;
    CGFloat voiceBgViewW = voiceImageViewW + 3 * M;
    if(_voiceMessage.showMessageIn == ShowMessageInLeft){
        _voiceImageView.image = [UIImage imageNamed:@"icon_voice_03_black"];
         _voiceImageView.frame = CGRectMake(0, 0, voiceImageViewW, voiceImageViewH);
    }else{
        _voiceImageView.image = [UIImage imageNamed:@"icon_voice_03_white"];
         _voiceImageView.frame = CGRectMake(voiceBgViewW - voiceImageViewW, 0, voiceImageViewW, voiceImageViewH);
    }
    
    _voiceBgView.frame = CGRectMake(M, M, _voiceImageView.frame.size.width + 3 * M, PJScale(14));
    
    _voiceImageView.animationImages = self.voiceAnimImages;
    _voiceImageView.animationDuration = 1.0;
    _voiceImageView.animationRepeatCount = _voiceMessage.voiceTime;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCell)];
    [self.messageContentView addGestureRecognizer:tap];
}

- (void)clickCell{
    NSLog(@"%@",self.voiceMessage.voiceName);
    [VoicePlayManager shareInstance].playUrl = self.voiceMessage.localUrl;
    if([VoicePlayManager shareInstance].voicePlayState == VoicePlaying){
        [[VoicePlayManager shareInstance] stopPlayVoice];
    }else{
        [[VoicePlayManager shareInstance] startPlayVoice];
    }
}

//开始播放语音
- (void)startPlayVoice{
    [_voiceImageView startAnimating];
}

//结束播放语音
- (void)stopPlayVoice{
    if([_voiceImageView isAnimating]){
        [_voiceImageView stopAnimating];
    }
}

- (NSArray *)voiceAnimImages {
    if (!_voiceAnimImages) {
        NSArray *receiverVoiceImgs = @[[UIImage imageNamed:@"icon_voice_01_black"], [UIImage imageNamed:@"icon_voice_02_black"], [UIImage imageNamed:@"icon_voice_03_black"]];
        
         NSArray *senderVoiceImgs = @[[UIImage imageNamed:@"icon_voice_01_white"], [UIImage imageNamed:@"icon_voice_02_white"], [UIImage imageNamed:@"icon_voice_03_white"]];
        _voiceAnimImages = self.message.showMessageIn == ShowMessageInRight ? senderVoiceImgs : receiverVoiceImgs;
    }
    return _voiceAnimImages;
}

@end
