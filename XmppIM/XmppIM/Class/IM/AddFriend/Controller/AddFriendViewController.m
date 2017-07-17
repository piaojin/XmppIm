//
//  AddFriendViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/7.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "AddFriendViewController.h"
#import "UserModel.h"

@interface AddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *friendNickName;


@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加好友";
}

- (IBAction)addClick:(id)sender {
    NSString *nickName = self.friendNickName.text;
    if([NSString isBlankString:nickName]){
        [SVProgressHUD showErrorWithStatus:@"好友昵称不能为空!"];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserModel *friend = [[UserModel alloc] init];
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",nickName,DoMain]];
        friend.jid = jid;
        friend.userName = nickName;
        [[XMPPManager shareInstanceManager] addFriend:friend];
    });
    
//    UserModel *friend = [[UserModel alloc] init];
//    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",nickName,DoMain]];
//    friend.jid = jid;
//    friend.userName = nickName;
//    [[XMPPManager shareInstanceManager] addFriend:friend];
    [SVProgressHUD showSuccessWithStatus:@"发起好友邀请成功!"];
}

@end
