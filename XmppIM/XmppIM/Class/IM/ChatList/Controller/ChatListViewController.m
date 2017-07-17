//
//  ChatListViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/7.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatListViewController.h"

@interface ChatListViewController ()

@property (nonatomic, strong)NSMutableArray *chatListArray;

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView{
    self.title = @"聊天列表";
    UIBarButtonItem *addFriendItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = addFriendItem;
}

- (void)logout{
    [[XMPPManager shareInstanceManager] logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
