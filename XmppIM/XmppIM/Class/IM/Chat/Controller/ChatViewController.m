//
//  ChatViewController.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "ChatViewController.h"
#import "UserModel.h"
#import "PJInputBar.h"
#import "ContentChatCell.h"
#import "PJMessage.h"
#import "PJContentMessage.h"
#import "PJImageMessage.h"
#import "PJVoiceMessage.h"
#import "ImageChatCell.h"
#import "VoiceChatCell.h"
#import "PJMessageTool.h"
#import "TZImagePickerController.h"
#import "PJCacheManager.h"
#import "PJDateTool.h"
#import "PreviewImageManager.h"

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)PJInputBar *inputBar;
//聊天信息列表
@property (nonatomic, strong)NSMutableArray<PJMessage *> *chatArray;

@end

@implementation ChatViewController

- (void)dealloc{
    [self.chatArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initNotifi];
}

- (void)initView{
    //标志用户是否在线
    //0:在线 1:离开 2:离线
    self.title = [NSString stringWithFormat:@"%@-%@",self.chatUserModel.userName,self.chatUserModel.xmppUserCoreDataStorageObject.sectionNum ? @"离线" : @"在线"];
    
    CGFloat inputBarH = 50;
    _inputBar = [[PJInputBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - inputBarH, self.view.bounds.size.width, inputBarH)];
    _inputBar.backgroundColor = RGBAColor(242, 245, 247);
    WeakSelf
    //发送文本消息
    _inputBar.sendClick = ^(NSString *messageContent) {
        NSLog(@"%@",messageContent);
        [weakSelf sendTextMessage];
    };
    
    //点击更多(暂时未选择图片)
    _inputBar.moreClick = ^{
        [weakSelf selectPicture];
    };
    
    //发送语音
    _inputBar.sendVoice = ^(PJVoiceMessage *voiceMessage) {
        [weakSelf sendVoiceMesage:voiceMessage];
    };
    
    [self.view addSubview:_inputBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - _inputBar.frame.size.height - 64)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = RGBAColor(237, 237, 237);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    [self.view addSubview:_tableView];
}

- (void)initData{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [[XMPPManager shareInstanceManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self loadChatHistory];
    [self tableViewScrollToBottom];
}

- (void)initNotifi{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

//加载聊天记录
- (void)loadChatHistory{
    WeakSelf
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPManager shareInstanceManager].xmppMessageArchivingCoreDataStorage;
    //查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", _chatUserModel.jid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (fetchedObjects != nil) {
            for(XMPPMessageArchiving_Message_CoreDataObject *messageObject in fetchedObjects){
                PJMessage *message = nil;
                message = [PJMessageTool dealWithMessage:messageObject.message];
                [weakSelf.chatArray addObject:message];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}

#pragma 照片处理与选择
- (void)selectPicture{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    [imagePickerVc.selectedAssets removeAllObjects];
    // 你可以通过block或者代理，来得到用户选择的照片.
    WeakSelf
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets,BOOL isSelectOriginalPhoto) {
        //暂时未只能发送每次只能发送一张图片
        NSLog(@"发送图片");
        [weakSelf sendImageMessage:photos.firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PJMessage *message = self.chatArray[indexPath.row];
    ChatCell *cell = nil;
    switch (message.messageType) {
        case PJMessageContentType:
            cell = [ContentChatCell cellWithTable:tableView];
            break;
        case PJMessageImageType:
            cell = [ImageChatCell cellWithTable:tableView];
            //点击浏览图片,这边只是最简单的显示图片而已,并无做任何其他处理
            ((ImageChatCell *)cell).clickImage = ^(UIImageView *pjimageView, PJImageMessage *imageMessage) {
                [PreviewImageManager showImage:pjimageView.image];
            };
            break;
        case PJMessageVoiceType:
            cell = [VoiceChatCell cellWithTable:tableView];
            break;
            
        default:
            break;
    }
    [cell setMessage:message];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.chatArray[indexPath.row].rowH;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

//发送文本消息
- (void)sendTextMessage{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_chatUserModel.jid];
    [message addBody:_inputBar.messageContent];
    [message addSubject:TextMessage];
    PJContentMessage *contentMessage = [[PJContentMessage alloc] initWithXMPPMessage:message];
    contentMessage.showMessageIn = ShowMessageInRight;
    [self.chatArray addObject:contentMessage];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    [[XMPPManager shareInstanceManager].xmppStream sendElement:message];
}

//发送图片消息
- (void)sendImageMessage:(UIImage *)image{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_chatUserModel.jid];
    [message addBody:ImageMessage];
    [message addSubject:ImageMessage];
    PJImageMessage *imageMessage = [[PJImageMessage alloc] initWithXMPPMessage:message];
    imageMessage.showMessageIn = ShowMessageInRight;
    //给图片取名
    imageMessage.imageName = [NSString stringWithFormat:@"%@%@",[[PJDateTool shareInstance] currentDate],_chatUserModel.userName];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageBase64Str = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    //自己发送的图片先缓存在发送
    [PJCacheManager cacheImage:imageData imageMessage:imageMessage];
    
    // 设置节点内容,图片的内容base64str
    XMPPElement *attachment = [XMPPElement elementWithName:ImageMessage stringValue:imageBase64Str];
    // 包含子节点
    [message addChild:attachment];
    
    // 图片的节点名称(图片的加载是通过图片名称在到缓存中查询加载)
    XMPPElement *imageAttachment = [XMPPElement elementWithName:XMPPElementImageMessage stringValue:imageMessage.imageName];
    // 包含子节点
    [message addChild:imageAttachment];
    
    [self.chatArray addObject:imageMessage];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    [[XMPPManager shareInstanceManager].xmppStream sendElement:message];
}

//发送语音消息
- (void)sendVoiceMesage:(PJVoiceMessage *)voiceMessage{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_chatUserModel.jid];
    [message addBody:VoiceMessage];
    [message addSubject:VoiceMessage];
    voiceMessage.showMessageIn = ShowMessageInRight;
    
    NSData *voiceData = [NSData dataWithContentsOfFile:voiceMessage.localUrl];
    NSString *voiceBase64Str = [voiceData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // 设置节点内容,语音的内容base64str
    XMPPElement *attachment = [XMPPElement elementWithName:VoiceMessage stringValue:voiceBase64Str];
    NSLog(@"voiceBase64Str:%@",voiceBase64Str);
    // 包含子节点
    [message addChild:attachment];
    
    // 语音的节点名称(语音的加载是通过语音名称在到缓存中查询加载)
    XMPPElement *voiceAttachment = [XMPPElement elementWithName:XMPPElementVoiceMessage stringValue:voiceMessage.voiceName];
    // 包含子节点
    [message addChild:voiceAttachment];
    
    [self.chatArray addObject:voiceMessage];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    [[XMPPManager shareInstanceManager].xmppStream sendElement:message];
}

//滚动到底部
- (void)tableViewScrollToBottom{
    if (_chatArray.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_chatArray.count-1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma 键盘事件

- (void)keyboardDidShow:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    WeakSelf
    [UIView animateWithDuration:duration.doubleValue animations:^{
//        weakSelf.inputBar.frame = CGRectMake(0, 74, weakSelf.inputBar.frame.size.width, weakSelf.inputBar.frame.size.height);
        weakSelf.inputBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
    }];
}

- (void)keyboardDidHide:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    WeakSelf
    [UIView animateWithDuration:duration.doubleValue animations:^{
//        weakSelf.inputBar.frame = CGRectMake(0, weakSelf.view.frame.size.height - weakSelf.inputBar.frame.size.height, weakSelf.inputBar.frame.size.width, weakSelf.inputBar.frame.size.height);
        weakSelf.inputBar.transform = CGAffineTransformIdentity;
    }];
}

#pragma xmppStream delegate
//消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"消息发送成功");
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"收到消息%s--%@",__FUNCTION__, message);
    //XEP--0136 已经用coreData实现了数据的接收和保存
    if(message.isChatMessageWithBody){
        PJMessage *receiveMessage = [PJMessageTool dealWithMessage:message];
        switch (receiveMessage.messageType) {
                //如果是图片消息需要对图片先进行缓存在通知用户新消息到来
            case PJMessageImageType:{
                WeakSelf
                [PJMessageTool dealReceiveImageMessage:(PJImageMessage *)receiveMessage xmppMessage:message imageBlock:^(PJImageMessage *imageMessage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf updateNewMessage:imageMessage];
                    });
                }];
                break;
            }
                //如果是语音消息需要对语音先进行缓存在通知用户新消息到来
            case PJMessageVoiceType:{
                WeakSelf
                [PJMessageTool dealReceiveVoiceMessage:(PJVoiceMessage *)receiveMessage xmppMessage:message voiceBlock:^(PJVoiceMessage *voiceMessage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf updateNewMessage:voiceMessage];
                    });
                }];
            }
                break;
            default:
                [self updateNewMessage:receiveMessage];
                break;
        }
    }
}

//消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"消息发送失败");
}

- (void)updateNewMessage:(PJMessage *)newMessage{
    [self.chatArray addObject:newMessage];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma setter,getter
- (NSMutableArray<PJMessage *> *)chatArray{
    if(!_chatArray){
        _chatArray = [NSMutableArray<PJMessage *> array];
    }
    return _chatArray;
}

@end
