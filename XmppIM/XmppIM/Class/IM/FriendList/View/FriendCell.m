//
//  FriendCell.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "FriendCell.h"
#import "UserModel.h"

@interface FriendCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nickName;


@end

@implementation FriendCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        cell = (FriendCell *)[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil].firstObject;
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatar.layer.cornerRadius = self.avatar.frame.size.height / 2.0;
    self.avatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    self.nickName.text = userModel.userName;
}

@end
