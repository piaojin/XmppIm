//
//  ChatCell.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

+ (instancetype)cellWithTable:(UITableView *)tableView{
    NSString *className = NSStringFromClass([self class]);
    NSString *ID = className;
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil){
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    self.backgroundColor = RGBAColor(237, 237, 237);
    _avatarLeft = [[UIButton alloc] init];
    //头像图片是盗用别人的
    [_avatarLeft setBackgroundImage:[UIImage imageNamed:@"lufei"] forState:(UIControlStateNormal)];
    [self.contentView addSubview:_avatarLeft];
    
    _avatarRight = [[UIButton alloc] init];
    //头像图片是盗用别人的
    [_avatarRight setBackgroundImage:[UIImage imageNamed:@"aisi"] forState:(UIControlStateNormal)];
    [self.contentView addSubview:_avatarRight];
    
    _messageContentView = [[PJMessageContentView alloc] init];
    _messageContentView.layer.cornerRadius = 6.0f;
    _messageContentView.layer.masksToBounds = YES;
    _messageContentView.userInteractionEnabled = YES;
    [self.contentView addSubview:_messageContentView];
}

- (void)setMessage:(PJMessage *)message{
    _message = message;
    
    CGFloat M = 10;
    CGFloat W = 28;
    CGFloat H = 28;
    
    if(_avatarLeft.frame.size.width <= 0){
        //头像的frame只需要设置一次即可
        _avatarLeft.frame = CGRectMake(M, M, W, H);
        _avatarRight.frame = CGRectMake(ScreenWidth - M - W, M, W, H);
    }
    
    CGRect messageContentViewRect;
    
    if(_message.showMessageIn == ShowMessageInLeft){
        _avatarRight.hidden = YES;
        _avatarLeft.hidden = NO;
        messageContentViewRect = CGRectMake(CGRectGetMaxX(_avatarLeft.frame) + M, _avatarLeft.frame.origin.y, self.message.messageContentSize.width + 2 * M, self.message.messageContentSize.height + 2 * M);
        _messageContentView.backgroundColor = [UIColor whiteColor];
    }else{
        _avatarLeft.hidden = YES;
        _avatarRight.hidden = NO;
        
        messageContentViewRect = CGRectMake(_avatarRight.frame.origin.x - 3 * M - self.message.messageContentSize.width, _avatarRight.frame.origin.y, self.message.messageContentSize.width + 2 * M, self.message.messageContentSize.height + 2 * M);
        _messageContentView.backgroundColor = [UIColor greenColor];
    }
    _messageContentView.frame = messageContentViewRect;
}

- (void)clickCell{
    NSLog(@"clickCell");
}

@end
