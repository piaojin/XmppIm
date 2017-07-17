//
//  TempViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/13.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "TempViewController.h"
#import "LoginViewController.h"
#import "PJCacheManager.h"
#import "PJTabBarVController.h"

@interface TempViewController ()

@end

@implementation TempViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNotification];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self autoLogin];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFaild) name:LoginFaild object:nil];
}

- (void)autoLogin{
    [SVProgressHUD showWithStatus:@"登录中..."];
    NSString *name = [PJCacheManager getCancheDataForKey:UserName];
    NSString *password = [PJCacheManager getCancheDataForKey:PassWord];
    
    if([NSString isBlankString:name] || [NSString isBlankString:password]){
        [self loginFaild];
        return;
    }
    
    [[XMPPManager shareInstanceManager] loginWithName:name password:password];
}

- (void)loginSuccess{
    [SVProgressHUD dismiss];
    PJTabBarVController *tabBarVController = [[PJTabBarVController alloc] init];
    [self presentViewController:tabBarVController animated:YES completion:nil];
}

- (void)loginFaild{
    [SVProgressHUD dismiss];
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

@end
