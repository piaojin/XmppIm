//
//  FriendListViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/7.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "FriendListViewController.h"
#import "AddFriendViewController.h"
#import "UserModel.h"
#import "FriendCell.h"
#import "ChatViewController.h"
#import "MJRefresh.h"

@interface FriendListViewController ()<XMPPRosterDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)MJRefreshNormalHeader *freshHeader;
@property (nonatomic, strong)NSMutableArray *contacts;
//好友查询相关
@property (nonatomic, strong)NSFetchedResultsController *resultContr;

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    //好友列表代理
    [[XMPPManager shareInstanceManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //主动拉取好友列表,不过这边拉取的好友是在线好友
    [[XMPPManager shareInstanceManager].xmppRoster fetchRoster];
}

- (void)initView{
    self.title = @"好友列表";
    UIBarButtonItem *addFriendItem = [[UIBarButtonItem alloc] initWithTitle:@"添加好友" style:UIBarButtonItemStylePlain target:self action:@selector(addFriendClick)];
    self.navigationItem.rightBarButtonItem = addFriendItem;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.mj_header = self.freshHeader;
    [self.freshHeader setTitle:@"下拉刷新" forState:(MJRefreshStateIdle)];
    [self.freshHeader setTitle:@"松开刷新" forState:(MJRefreshStatePulling)];
    [self.freshHeader setTitle:@"刷新中..." forState:(MJRefreshStateRefreshing)];
    self.freshHeader.lastUpdatedTimeLabel.hidden = YES;
    self.freshHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
    self.freshHeader.stateLabel.textColor = RGBAColor(178, 178, 178);
    self.freshHeader.arrowView.alpha = 0;
    [self.view addSubview:_tableView];
}

- (void)initData{
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)addFriendClick{
    AddFriendViewController *addFriendViewController = [[AddFriendViewController alloc] init];
    addFriendViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendViewController animated:YES];
}

#pragma mark -- 好友列表协议方法
/**
 * 开始同步服务器发送过来的自己的好友列表
 **/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    
}

//收到每一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    //得到item的jid
    NSString *jid = [[item attributeForName:@"jid"]stringValue];
    
    //转换成XMPPJID类型
    XMPPJID *userJID = [XMPPJID jidWithString:jid];
    NSLog(@"%@",[userJID user]);
    UserModel *friend = [[UserModel alloc] initWithJid:userJID];
    [self.contacts addObject:friend];
}

/**
 *  好友列表加载
 NSFetchedResultsController，官方解释是可以有效地管理从Core Data读取到的提供给UITableView对象的数据。
 
 使用方法分为3步：
 1. 配置一个request，指定要查询的数据库表
 2. 至少为获取到的数据设置一个排序方法
 3. 可以为数据设置过滤条件
 
 除此之外，它还提供以下两个功能：
 1. 监听和它关联的上下文（NSManagedObjectContext）的改变，并报告这些改变
 2. 缓存结果，重新显示相同的数据的时候不需要再获取一遍
 */
- (void)loadFreinds{
    //显示好友数据（保存在XMPPRoster.sqlite）
    //1.上下文，关联XMPPRoster.sqlite
    NSManagedObjectContext *rosterContext = [[XMPPManager shareInstanceManager].xmppRosterCoreDataStorage mainThreadManagedObjectContext];
    
    //2.请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //过滤没有添加成功的好友
    //语法和sql一样
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription != %@", @"none"];
    request.predicate = predicate;
    
    //3.执行请求
    //3.1创建结果控制器
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    //3.2执行
    NSError *error = nil;
    [_resultContr performFetch:&error];
    
    for(XMPPUserCoreDataStorageObject *user in _resultContr.fetchedObjects){
        NSLog(@"好友:%@",user.displayName);
        UserModel *friend = [[UserModel alloc] initWithXMPPUserCoreDataStorageObject:user];
        [self.contacts addObject:friend];
    }
}

/**
 * 同步结束
 **/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"获取好友列表结束,此处向外部传值");
    [self loadFreinds];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark 结果控制器代理方法
#pragma mark 数据库内容改变
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

- (void)beginPullDownRefreshing{
    //主动拉取好友列表,不过这边拉取的好友是在线好友
    [[XMPPManager shareInstanceManager].xmppRoster fetchRoster];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *cell = [FriendCell cellWithTableView:tableView];
    cell.userModel = self.contacts[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.hidesBottomBarWhenPushed = YES;
    chatViewController.chatUserModel = self.contacts[indexPath.row];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (NSMutableArray *)contacts{
    if(!_contacts){
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

- (MJRefreshNormalHeader *)freshHeader{
    if(!_freshHeader){
        _freshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(beginPullDownRefreshing)];
    }
    return _freshHeader;
}

@end
