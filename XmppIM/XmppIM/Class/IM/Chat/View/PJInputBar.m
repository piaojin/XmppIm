//
//  PJInputBar.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJInputBar.h"
#import "VoiceManager.h"
#import "PJVoiceMessage.h"

@interface PJInputBar ()<UITextViewDelegate>

//录音管理类
@property (nonatomic, strong)VoiceManager *voiceManager;

@end

@implementation PJInputBar

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self initView];
    }
    return self;
}

- (void)initView{
    CGFloat M = 5;
    CGFloat W = self.frame.size.height - 2 * M;
    CGFloat H = W;
    _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(M, M, W, H)];
    [_voiceButton setBackgroundImage:[UIImage imageNamed:@"ico_voice"] forState:(UIControlStateNormal)];
    [self addSubview:_voiceButton];
    
    _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - M - W, M, W, H)];
    [_moreButton setBackgroundImage:[UIImage imageNamed:@"ico_more"] forState:(UIControlStateNormal)];
    [self addSubview:_moreButton];
    
    CGFloat inputTextViewM = 4;
    CGFloat inputTextViewH = self.frame.size.height - 2 * inputTextViewM;
    CGFloat inputTextViewW = self.frame.size.width - CGRectGetMaxX(_voiceButton.frame) - 2 * M - _moreButton.frame.size.width - 3 * M;
    _inputTextView = [[PJInputTextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_voiceButton.frame) + 2 * M, inputTextViewM, inputTextViewW, inputTextViewH)];
    _inputTextView.layer.cornerRadius = 6.0f;
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.font = [UIFont systemFontOfSize:16.0];
    _inputTextView.hidden = _isVoice;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInputTextView)];
    [_inputTextView addGestureRecognizer:tap];
    [self addSubview:_inputTextView];
    
    _recordButton = [[PJRecordButton alloc] initWithFrame:_inputTextView.frame];
    [_recordButton setTitle:@"按住说话" forState:(UIControlStateNormal)];
//    [_recordButton setTitle:@"录制中..." forState:(UIControlStateHighlighted)];
    _recordButton.layer.cornerRadius = 6.0f;
    _recordButton.layer.masksToBounds = YES;
    _recordButton.backgroundColor = [UIColor whiteColor];
    [_recordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_recordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _recordButton.hidden = !_isVoice;
    [self addSubview:_recordButton];
    
    [_voiceButton addTarget:self action:@selector(clickVoice) forControlEvents:(UIControlEventTouchUpInside)];
    [_moreButton addTarget:self action:@selector(clickMore) forControlEvents:(UIControlEventTouchUpInside)];
    
#pragma 录音按钮长按手势
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_recordButton addGestureRecognizer:longTap];
}

#pragma 按钮点击事件

- (void)longPress:(UILongPressGestureRecognizer *)press {
    switch (press.state) {
        case UIGestureRecognizerStateBegan : {
            //开始录音
            if([self.voiceManager startRecord]){
                 [_recordButton setTitle:@"录制中..." forState:(UIControlStateNormal)];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [press locationInView:self.window];
            NSLog(@"change:%f",point.y);
            if(point.y < self.frame.origin.y){
                //处于上滑取消录音状态
                if(self.voiceManager.voiceState != RecordPause){
                    [self.voiceManager pauseRecord];
                }
            }else{
                if(self.voiceManager.voiceState != Recording){
                    [self.voiceManager continueRecord];
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            //手指离开录音按钮结束录音
            [self endPress];
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}

- (void)endPress{
    [_recordButton setTitle:@"按住说话" forState:(UIControlStateNormal)];
    
    if(self.voiceManager.voiceState == RecordPause){
        //取消语音
        [self.voiceManager cancelRecord];
    }else if(self.voiceManager.voiceState == Recording){
        if(self.voiceManager.recordTime < MinRecordTime){
            [SVProgressHUD showErrorWithStatus:@"语音时间过短"];
            //取消语音即删除本地语音
            [self.voiceManager cancelRecord];
        }else{
            //录制完毕可以发送语音
            [self.voiceManager stopRecord];
        }
    }
}

- (void)clickVoice{
    _isVoice = !_isVoice;
    _inputTextView.hidden = _isVoice;
    _recordButton.hidden = !_isVoice;
}

- (void)clickMore{
    NSLog(@"点击了更多");
    if(_moreClick){
        _moreClick();
    }
}

- (void)clickInputTextView{
    [_inputTextView becomeFirstResponder];
}

#pragma 键盘代理
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"点击了发送");
    //如果为回车则将键盘收起
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendTextMessage];
        return NO;
    }
    return YES;
}

- (void)sendTextMessage{
    NSLog(@"点击了发送");
    NSString *messageContent = _inputTextView.text;
    if(_sendClick && ![NSString isBlankString:messageContent]){
        _sendClick(messageContent);
        _inputTextView.text = @"";
    }
}

- (NSString *)messageContent{
    return _inputTextView.text;
}

- (VoiceManager *)voiceManager{
    if(!_voiceManager){
        _voiceManager = [VoiceManager shareInstance];
        //录音完成发送语音
        WeakSelf
        _voiceManager.sendVoice = ^(PJVoiceMessage *voiceMessage) {
            if(weakSelf.sendVoice){
                weakSelf.sendVoice(voiceMessage);
            }
        };
    }
    return _voiceManager;
}

@end

@implementation PJInputTextView



@end

@implementation PJRecordButton



@end
