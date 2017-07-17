//
//  LoginViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "LoginViewController.h"
#import "PJTabBarVController.h"
#import "PJCacheManager.h"

@interface LoginViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    [self initNotification];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LoginSuccess object:nil];
}

//登录
- (IBAction)login:(id)sender {
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    if([NSString isBlankString:userName] || [NSString isBlankString:password]){
        [SVProgressHUD showErrorWithStatus:@"账号或密码不能为空!"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"登录中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //登录前需要重新初始化相关数据,因为退出登录的时候会清空这些数据
        [[XMPPManager shareInstanceManager] setUpDelegateAndActivate];
        [[XMPPManager shareInstanceManager] loginWithName:userName password:password];
    });
}

//注册
- (IBAction)register:(id)sender {
    
}

- (void)loginSuccess{
    [SVProgressHUD dismiss];
    //简单的保存用户名和密码
    [PJCacheManager cacheData:self.userNameField.text Key:UserName];
    [PJCacheManager cacheData:self.passwordField.text Key:PassWord];
    PJTabBarVController *tabBarVController = [[PJTabBarVController alloc] init];
    [self presentViewController:tabBarVController animated:YES completion:nil];
}


@end
