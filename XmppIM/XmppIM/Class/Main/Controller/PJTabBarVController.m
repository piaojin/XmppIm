//
//  PJTabBarVController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/7.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJTabBarVController.h"
#import "FriendListViewController.h"
#import "ChatListViewController.h"

@interface PJTabBarVController ()

@end

@implementation PJTabBarVController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViewControllers];
}

- (void)addSubViewControllers{
    //聊天列表
    ChatListViewController *chatListViewController = [[ChatListViewController alloc] init];
    UINavigationController *chatListNav = [[UINavigationController alloc] initWithRootViewController:chatListViewController];
    UITabBarItem *chatListViewControllerItem = [[UITabBarItem alloc]initWithTitle:@"聊天列表" image:[UIImage imageNamed:@"tabbar_disc"] selectedImage:[UIImage imageNamed:@"tabbar_disc_hover"]];
    chatListViewController.tabBarItem = chatListViewControllerItem;
    
    //好友列表
    FriendListViewController *friendListViewController = [[FriendListViewController alloc] init];
    UINavigationController *friendListNav = [[UINavigationController alloc] initWithRootViewController:friendListViewController];
    UITabBarItem *friendListViewControllerItem = [[UITabBarItem alloc]initWithTitle:@"好友列表" image:[UIImage imageNamed:@"tabbar_mates"] selectedImage:[UIImage imageNamed:@"tabbar_mates_hover"]];
    friendListViewController.tabBarItem = friendListViewControllerItem;
    
    self.viewControllers = @[chatListNav,friendListNav];
}

@end
