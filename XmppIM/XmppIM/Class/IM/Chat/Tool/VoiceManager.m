//
//  VoiceManager.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/15.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "VoiceManager.h"
#import "PJCacheManager.h"
#import "PJDateTool.h"
#import "PJVoiceMessage.h"

@interface VoiceManager ()<AVAudioRecorderDelegate>

@property (nonatomic, strong)UIView *voiceBgView;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)UIImageView *voiceLevelImageView;
@property (nonatomic, strong)UIImageView *voiceImageView;
@property (nonatomic, strong)UIImageView *voiceCancelImageView;
@property (nonatomic, strong)UILabel *voiceLabel;

@end

@implementation VoiceManager

- (void)dealloc{
    [self.recordTimer invalidate];
    [self.levelTimer invalidate];
    [self setRecordTimer:nil];
    [self setLevelTimer:nil];
    if(![self.audioRecorder isRecording]){
        [self.audioRecorder stop];
    }
    [self setAudioRecorder:nil];
    [self setVoiceBgView:nil];
}

+ (instancetype)shareInstance{
    static VoiceManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[VoiceManager alloc] init];
    });
    return shareManager;
}

//基本步骤：1.进行录音设置（先配置录音机（是一个字典），设置录音的格式，录音的采样率，录音的先行采样位数，录音的通道数，录音质量，录音路径，初始化录音对象，开启音量检测）；2.设置录音按钮的功能（UI设置）3.设置播放按钮并实现播放功能
//开始录音
- (BOOL)startRecord{
    switch ([AVAudioSession sharedInstance].recordPermission) {
        // 请求授权
        case AVAudioSessionRecordPermissionUndetermined: {
            
            if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
                [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    
                    if (granted) {
                        NSLog(@"授权成功");
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[UIAlertView alloc] initWithTitle:nil
                                                        message:@"没有麦克风权限"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil] show];
                        });
                    }
                }];
            }
        }
            break;
            
        case AVAudioSessionRecordPermissionDenied: {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:@"没有麦克风权限"
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil] show];
            });
            
        }
            break;
            
        case AVAudioSessionRecordPermissionGranted: { //已授权
            //创建录音文件，准备录音
            if([self.audioRecorder prepareToRecord]){
                [self.audioRecorder record];
                NSLog(@"开始录音");
                [self showRecorder];
                [self setVoiceState:Recording];
                [self.recordTimer fire];
                [self.levelTimer fire];
                return YES;
            }else{
                NSLog(@"录音失败");
                [self stopRecord];
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    return NO;
}

//停止录音
- (void)stopRecord{
    if([self.audioRecorder isRecording]){
        [self.audioRecorder stop];
    }
    NSLog(@"停止录音");
    [self closeRecorder];
    [self sendFinishVoice];
    [self.recordTimer invalidate];
    [self.levelTimer invalidate];
    [self setRecordTimer:nil];
    [self setLevelTimer:nil];
    [self setVoiceCachePath:nil];
    [self setVoiceName:nil];
    [self setRecordTime:0];
    [self setVoiceState:RecordEnd];
    [self setAudioRecorder:nil];
}

//取消录音
- (void)cancelRecord{
    if([self.audioRecorder isRecording]){
        [self.audioRecorder stop];
    }
    NSLog(@"取消录音");
    [self closeRecorder];
    [self sendCancelVoice];
    [self.recordTimer invalidate];
    [self.levelTimer invalidate];
    [self setRecordTimer:nil];
    [self setLevelTimer:nil];
    [self setVoiceCachePath:nil];
    [self setVoiceName:nil];
    [self setRecordTime:0];
    [self setVoiceState:RecordEnd];
    //删除本地语音
    if(![self.audioRecorder isRecording]){
        [self.audioRecorder deleteRecording];
    }
    [self setAudioRecorder:nil];
}

//暂停录音
- (void)pauseRecord{
    [self.audioRecorder pause];
    NSLog(@"暂停录音");
    [self showPauseRecorder];
    [self.recordTimer invalidate];
    [self.levelTimer invalidate];
    [self setRecordTimer:nil];
    [self setLevelTimer:nil];
    [self setVoiceState:RecordPause];
}

//继续录音
- (void)continueRecord{
    NSLog(@"继续录音");
    [self.audioRecorder record];
    [self showRecorder];
    [self.recordTimer fire];
    [self.levelTimer fire];
    [self setVoiceState:Recording];
}

//显示录音界面
- (void)showRecorder{
    if(!_voiceBgView){
        [self.window addSubview:self.voiceBgView];
    }
    _voiceBgView.hidden = NO;
    _contentView.hidden = NO;
    _voiceCancelImageView.hidden = YES;
    self.voiceLabel.text = @"手指上滑,取消发送";
    self.voiceLabel.backgroundColor = [UIColor clearColor];
    self.voiceLabel.alpha = 1.0;
}

//显示取消录音界面
- (void)showPauseRecorder{
    if(!_voiceBgView){
        [self.window addSubview:self.voiceBgView];
    }
    _voiceBgView.hidden = NO;
    _contentView.hidden = YES;
    _voiceCancelImageView.hidden = NO;
    self.voiceLabel.text = @"手指松开取消发送";
    self.voiceLabel.backgroundColor = [UIColor redColor];
    self.voiceLabel.alpha = 0.7;
}

//关闭录音界面
- (void)closeRecorder{
    _voiceBgView.hidden = YES;
}

#pragma 录音delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"%@",error);
}

//录音完成发送语音
- (void)sendFinishVoice{
    if(_sendVoice){
        PJVoiceMessage *voiceMessage = [[PJVoiceMessage alloc] init];
        voiceMessage.messageType = PJMessageVoiceType;
        voiceMessage.voiceName = self.voiceName;
        voiceMessage.localUrl = self.voiceCachePath;
        NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        // 初始化视频媒体文件
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:voiceMessage.localUrl] options:opts];
        NSUInteger second = 0;
        // 获取视频总时长,单位秒
        second = urlAsset.duration.value / urlAsset.duration.timescale;
        voiceMessage.voiceTime = second;
        _sendVoice(voiceMessage);
    }
}

//取消发送语音
- (void)sendCancelVoice{
    if(_cancelVoice){
        _cancelVoice();
    }
}

//检测当前声音
- (void)detectionVioce{
    //刷新当前音量数据
    [_audioRecorder updateMeters];
    //获取音量的平均值
    double lowPassResults = pow(10, (0.05 * [_audioRecorder peakPowerForChannel:0]));//×于当前音量
    //现在取值范围在0~1   (每隔0.7)
    if(0 < lowPassResults < 0.06){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_1"]];
    }else if( 0.06< lowPassResults <= 0.13){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_2"]];
    }else if( 0.13<lowPassResults <= 0.20){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_3"]];
    }else if( 0.20 <lowPassResults <= 0.27){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_4"]];
    }else if( 0.27 <lowPassResults <= 0.34){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_5"]];
    }else if( 0.34 <lowPassResults <= 0.41){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_6"]];
    }else if( 0.41 <lowPassResults <= 0.48){
        [self.voiceLevelImageView setImage:[UIImage imageNamed:@"voice_level_6"]];
    }
}

- (NSString *)voiceCachePath{
    if(!_voiceCachePath){
        _voiceCachePath = [PJCacheManager voiceCachePath:self.voiceName];
    }
    return _voiceCachePath;
}

- (UIWindow *)window{
    if(!_window){
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (UIView *)voiceBgView{
    if(!_voiceBgView){
        CGFloat voiceBgViewW = PJScale(133);
        CGFloat voiceBgViewH = voiceBgViewW;
        CGFloat voiceBgViewX = (self.window.bounds.size.width - voiceBgViewW) / 2.0;
        CGFloat voiceBgViewY = PJScale(180);
        _voiceBgView = [[UIView alloc] initWithFrame:CGRectMake(voiceBgViewX, voiceBgViewY, voiceBgViewW, voiceBgViewH)];
        _voiceBgView.backgroundColor = [UIColor blackColor];
        _voiceBgView.alpha = 0.5;
        _voiceBgView.layer.cornerRadius = 6.0;
        _voiceBgView.layer.masksToBounds = YES;
        [_voiceBgView addSubview:self.contentView];
        [_voiceBgView addSubview:self.voiceLabel];
        [_voiceBgView addSubview:self.voiceCancelImageView];
    }
    return _voiceBgView;
}

- (UIView *)contentView{
    if(!_contentView){
        CGFloat contentViewW = PJScale(63);
        CGFloat contentViewH = PJScale(59);
        CGFloat contentViewX = (self.voiceBgView.bounds.size.width - contentViewW) / 2.0;
        CGFloat contentViewY = PJScale(30);
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH)];
        
        [_contentView addSubview:self.voiceImageView];
        [_contentView addSubview:self.voiceLevelImageView];
    }
    return _contentView;
}

- (UIImageView *)voiceImageView{
    if(!_voiceImageView){
        _voiceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_voice_speak"]];
        _voiceImageView.frame = CGRectMake(0, 0, PJScale(33), PJScale(59));
    }
    return _voiceImageView;
}

- (UIImageView *)voiceLevelImageView{
    if(!_voiceLevelImageView){
        CGFloat voiceLevelW = PJScale(18);
        CGFloat voiceLevelH = PJScale(45);
        CGFloat voiceLevelX = self.contentView.bounds.size.width - voiceLevelW;
        CGFloat voiceLevelY = self.contentView.bounds.size.height - voiceLevelH;
        _voiceLevelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_level_1"]];
        _voiceLevelImageView.frame = CGRectMake(voiceLevelX, voiceLevelY, voiceLevelW, voiceLevelH);
    }
    return _voiceLevelImageView;
}

- (UILabel *)voiceLabel{
    if(!_voiceLabel){
        _voiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.voiceBgView.bounds.size.height - PJScale(25), self.voiceBgView.bounds.size.width, PJScale(15))];
        [_voiceLabel setTextColor:[UIColor whiteColor]];
        [_voiceLabel setTextAlignment:(NSTextAlignmentCenter)];
        _voiceLabel.font = [UIFont systemFontOfSize:PJScale(14.0)];
    }
    return _voiceLabel;
}

- (UIImageView *)voiceCancelImageView{
    if(!_voiceCancelImageView){
        CGFloat voiceCancelViewW = PJScale(43);
        CGFloat voiceCancelViewH = PJScale(55);
        CGFloat voiceCancelViewX = (self.voiceBgView.bounds.size.width - voiceCancelViewW) / 2.0;
        CGFloat voiceCancelViewY = PJScale(30);
        _voiceCancelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel_voice"]];
        _voiceCancelImageView.hidden = YES;
        _voiceCancelImageView.frame = CGRectMake(voiceCancelViewX, voiceCancelViewY, voiceCancelViewW, voiceCancelViewH);
    }
    return _voiceCancelImageView;
}

- (AVAudioRecorder *)audioRecorder{
    if(!_audioRecorder){
        AVAudioSession *session =[AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if (session == nil || sessionError) {
            NSLog(@"Error creating session: %@,sessionError:%@",[sessionError description],sessionError);
        }else{
            [session setActive:YES error:nil];
        }
        
        self.session = session;
        
        //设置参数
        NSMutableDictionary *recorderSetting = [NSMutableDictionary dictionary];
        //2.设置录音的格式 / *在2000年被用在MPEG-4中（ISO 14496-3 Audio），所以现在变更为MPEG-4 AAC标准，也就是说，AAC已经成为MPEG4家族的主要成员之一，它是MPEG4第三部分中的音频编码系统。AAC可提供最多48个全音域音频通道。*/
        [recorderSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        
        //3.设置录音采样率 --采样频率是指录音设备在一秒钟内对声音信号的采样次数，采样频率越高声音的还原就越真实越自然。在当今的主流声卡上，采样频率一般共分为22.05KHz、44.1KHz、48KHz三个等级，22.05只能达到FM广播的声音品质，44.1KHz则是理论上的CD音质界限，48KHz则更加精确一些
        [recorderSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
        
        //4.设置录音的通道数
        [recorderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        
        //5.线性采样位数 8 ，16 ，24 ，32、采样位数可以理解为声卡处理声音的解析度。这个数值越大，解析度就越高，录制和回放的声音就越真实 --一般都是16位的（2的16次方）
        /*
        PCM的基本参数是采样频率和采样位深，采样频率就是每秒采样多少次，位深就是声音通过拾音器转成的电平信号被量化的精细度，同时也代表一次采样会用多少位保存
        */
        [recorderSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        //6,录音质量
        [recorderSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
        NSError *audioRecorderError;
        
        //录音文件的保存路径需要提前创建
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.voiceCachePath] settings:recorderSetting error:&audioRecorderError];
        
        if (_audioRecorder && !audioRecorderError) {
            _audioRecorder.meteringEnabled = YES;
        }else{
            NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder:%@",audioRecorderError);
        }
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

- (NSString *)voiceName{
    if(!_voiceName){
        _voiceName = [NSString stringWithFormat:@"%@@%@",[[PJDateTool shareInstance] currentDate],[XMPPManager shareInstanceManager].currentUser.userName];
    }
    return _voiceName;
}

- (NSTimer *)recordTimer{
    if(!_recordTimer){
        //定时器只是简单的添加到当前的线程(主线程,如果滑动UI会影响定时器的准准确度)RunLoop中,实际中可以添加到子线程的RunLoop中以提高计时准确度
        _recordTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(recording) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_recordTimer forMode:NSDefaultRunLoopMode];
    }
    return _recordTimer;
}

- (void)recording{
    self.recordTime = self.audioRecorder.currentTime;
    NSLog(@"recordTime:%f",self.recordTime);
    //录音最多录制60秒
    if(self.recordTime >= MaxRecordTime){
        [self stopRecord];
    }
}

- (NSTimer *)levelTimer{
    if(!_levelTimer){
        //定时器只是简单的添加到当前的线程(主线程,如果滑动UI会影响定时器的准准确度)RunLoop中,实际中可以添加到子线程的RunLoop中以提高计时准确度
        _levelTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(detectionVioce) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_levelTimer forMode:NSDefaultRunLoopMode];
    }
    return _levelTimer;
}

@end
