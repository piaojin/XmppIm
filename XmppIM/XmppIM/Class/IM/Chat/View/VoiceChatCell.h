//
//  VoiceChatCell.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/12.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatCell.h"
@class PJVoiceMessage;

@interface VoiceChatCell : ChatCell

@property (nonatomic, strong)PJVoiceMessage *voiceMessage;

@end
