//
//  ContentChatCell.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ContentChatCell.h"
#import "PJContentMessage.h"

@interface ContentChatCell ()

@property (nonatomic, strong)UILabel *contentLabel;

@end

@implementation ContentChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initView];
    }
    return self;
}

- (void)initView{
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:16.0];
    [self.messageContentView addSubview:_contentLabel];
}

- (void)setMessage:(PJMessage *)message{
    //一定先要去调用父类的,去做一些初始化工作
    [super setMessage:message];
    _contentMessage = (PJContentMessage *)message;
    _contentLabel.frame = CGRectMake(M, M, _contentMessage.messageContentSize.width, _contentMessage.messageContentSize.height);
    _contentLabel.text = _contentMessage.content;
}

@end
