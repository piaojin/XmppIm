//
//  FriendCell.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@interface FriendCell : UITableViewCell

@property (nonatomic, strong)UserModel *userModel;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
