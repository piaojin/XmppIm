//
//  ChatCell.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJMessage.h"
#import "PJMessageContentView.h"
@interface ChatCell : UITableViewCell

@property (nonatomic, strong)PJMessage *message;
@property (strong, nonatomic)UIButton *avatarLeft;
@property (strong, nonatomic)UIButton *avatarRight;
@property (nonatomic, strong)PJMessageContentView *messageContentView;

+ (instancetype)cellWithTable:(UITableView *)tableView;
//点击cell
- (void)clickCell;

@end
