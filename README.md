# XmppIm
### 时间过得很快,我的第一份iOS工作做的就是IM应用(选用的是XMPP),如今也忘得差不多了.利用空闲时间来重写一遍小Demo就当复习一下.
### 原理我就不介绍了,服务器的安装与配置可以参考[XMPP的mysql和openfire环境配置](XMPP的mysql和openfire环境配置)或者[配置介绍这篇](http://blog.csdn.net/u013087513/article/details/49669185)
### [环境配置转自陈怀哲首发自简](http://www.jianshu.com/p/8894a5a71b70)开始吧!
## 我做的简书地址为:(简书地址)[http://www.jianshu.com/p/c196135efc45]里面有很多BUG不要太介意
### 先来一个流程图:
![](http://upload-images.jianshu.io/upload_images/530099-405500d49adc357e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> ## 必要介绍
#### JID

#### XMPP的地址叫做JabberID（简写为JID），它用来标示XMPP网络中的各个XMPP实体。JID由三部分组成：domain，node identifier和resource。JID中domain是必不可少的部分。注意：domain和user部分是不分大小写的，但是resource区分大小写。
```
jid = [ node "@" ] domain [ "/" resource ]  
domain = fqdn / address-literal  
fqdn = (sub-domain 1*("." sub-domain))  
sub-domain = (internationalized domain label)  
address-literal = IPv4address / IPv6address  
```
#### domain：通常指网络中的网关或者服务器。
#### node identifier：通常表示一个向服务器或网关请求和使用网络服务的实体(比如一个客户端),当然它也能够表示其他的实体(比如在多用户聊天系统中的一个房间)。
#### resource：通常表示一个特定的会话（与某个设备），连接（与某个地址），或者一个附属于某个节点ID实体相关实体的对象（比如多用户聊天室中的一个参加者）。

#### JID种类有：
```
bare JID：user@domain.tld
full JID：user@domain.tld/resource
```
#### 例子：
#### stpeter@jabber.org：表示服务器jabber.org上的用户stpeter。 
#### room@service：一个用来提供多用户聊天服务的特定的聊天室。这里 “room“ 是聊天室的名字， ”service“ 是多用户聊天服务的主机名。 
#### room@service/nick：加入了聊天室的用户nick的地址。这里 “room“ 是聊天室的名字， ”service“ 是多用户聊天服务的主机名，”nick“ 是用户在聊天室的昵称。 

#### 为了标示JID，XMPP也有自己的URI，例如xmpp:stpeter@jabber.org，默认规则是在JID前加 xmpp:。
#### 通信原语


#### XMPP通信原语有3种：message、presence和iq。
#### 5.1 message
#### message是一种基本推送消息方法，它不要求响应。主要用于IM、groupChat、alert和notification之类的应用中。
#### 主要 属性如下：
#### 5.1.1  type属性，它主要有5种类型：
#### normal：类似于email，主要特点是不要求响应；
#### chat：类似于qq里的好友即时聊天，主要特点是实时通讯；
#### groupchat：类似于聊天室里的群聊；
#### headline：用于发送alert和notification；
#### error：如果发送message出错，发现错误的实体会用这个类别来通知发送者出错了；
#### 5.1.2  to属性：标识消息的接收方。
#### 5.1.3  from属性：指发送方的名字或标示。为防止地址外泄，这个地址通常由发送者的server填写，而不是发送者。

#### 载荷（payload）：例如body，subject

#### 例子：
```
<message  
  to="lily@jabber.org/contact"  
  type="chat" > 
    <body> 你好，在忙吗</body> 
</message> 
```

#### 5.2 presence
#### presence用来表明用户的状态，如：online、away、dnd(请勿打扰)等。当改变自己的状态时，就会在stream的上下文中插入一个Presence元素，来表明自身的状态。要想接受presence消息，必须经过一个叫做presence subscription的授权过程。 
#### 5.2.1 属性：
#### 5.2.1.1 type属性，非必须。有以下类别
#### subscribe：订阅其他用户的状态
#### probe：请求获取其他用户的状态
#### unavailable：不可用，离线（offline）状态
#### 5.2.1.2 to属性：标识消息的接收方。
#### 5.2.1.3 from属性：指发送方的名字或标示。

#### 5.2.2 载荷（payload）： 
#### 5.2.2.1 show：
#### chat：聊天中
#### away：暂时离开
#### xa：eXtend Away，长时间离开
#### dnd：勿打扰
#### 5.2.2.2 status：格式自由，可阅读的文本。也叫做rich presence或者extended presence，常用来表示用户当前心情，活动，听的歌曲，看的视频，所在的聊天室，访问的网页，玩的游戏等等。
#### 5.2.2.3 priority：范围-128~127。高优先级的resource能接受发送到bare JID的消息，低优先级的resource不能。优先级为负数的resource不能收到发送到bare JID的消息。

#### 例子：
```
<presence from="alice@wonderland.lit/pda"> 
  <show>xa</show> 
  <status>down the rabbit hole!</status> 
</presence> 
```

#### 5.3 iq （Info / Query）
#### 一种请求／响应机制，从一个实体从发送请求，另外一个实体接受请求，并进行响应。例如，client在stream的上下文中插入一个元素，向Server请求得到自己的好友列表，Server返回一个，里面是请求的结果。 
#### 主要的属性是type。包括: 
#### Get :获取当前域值。类似于http get方法。
#### Set :设置或替换get查询的值。类似于http put方法。
#### Result :说明成功的响应了先前的查询。类似于http状态码200。
#### Error: 查询和响应中出现的错误。
#### 例子：
```
<iq from="alice@wonderland.lit/pda"  
    id="rr82a1z7" 
    to="alice@wonderland.lit"  
    type="get"> 
  <query xmlns="jabber:iq:roster"/> 
</iq> 
```

> ## XMPPFramework结构与核心类

#### 在进入下一步之前，先给大家讲讲XMPPFramework的目录结构，以便新手们更容易读懂文章。我们来看看下图：
#### 虽然这里有很多个目录，但是我们在开发中基本只关心Core和Extensions这两个目录下的类。各个目录主要用来干嘛的？
#### Authentication：这一看名字就知道与授权验证相关的。
#### Categories：主要是一些扩展，尤其是NSXMLElement+XMPP扩展是必备的。
#### Core：这里是XMPP的核心文件目录，我们最主要的目光还是要放在这个目录上。
#### Extensions：这个目录是XMPP的扩展，用于扩展各种协议和各种独立的功能，其下每个子目录都是对应的一个单独的子功能。我们最常用到的功能有Reconnect、Roster、CoreDataStorage等。
#### Utilities：都是辅助类，我们开发者不用关心这里。
#### Vendor：这个目录是XMPP所引用的第三方类库，如CocoaAsyncSocket、KissXML等，我们也不用关心这里。
#### 阅读到此，对XMPPFramework的结构有所了解了吧！
#### 概念知识
#### 登录需要到账号，而所谓的账号其实就是用户唯一标识符（JID），在XMPP中使用XMPPJID类来表示。那么，用户唯一标识（JID）有什么组成？
#### JID一般由三部分构成：用户名，域名和资源名，格式为user@domain/resource，例如： test@example.com /Anthony。对应于XMPPJID类中的三个属性user、domain、resource。 
#### 如果没有设置主机名（HOST），则使用JID的域名（domain）作为主机名，而端口号是可选的，默认是5222，一般也没有必要改动它。
#### XMPPStream类
#### 我们要与服务器连接，就必须通过XMPPStream类了，它提供了很多的API和属性设置，通过socket来实现的。我们看到Verdor目录了吗，包含了CocoaAsyncSocket这个非常有名的socket编程库。XMPPStream类还遵守并实现了GCDAsyncSocketDelegate代理，用于客户端与服务器交互。
 
```
@interface XMPPStream : NSObject <GCDAsyncSocketDelegate>
```
 
#### 当我们创建XMPPStream对象后，我们需要设置代理，才能回调我们的代理方法，这个是支持multicast delegate，也就是说对于一个XMPPStream对象，可以设置多个代理对象，其中协议是XMPPStreamDelegate：
 
```
- (void)addDelegate:(id)delegatedelegateQueue:(dispatch_queue_t)delegateQueue;
```
 
#### 而当我们不希望某个XMPPStream对象继续接收到代理回调时，我们通过这样的方式来移除代理：

```
- (void)removeDelegate:(id)delegatedelegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;
```
 
#### 接下来，我们要设置主机和端口，通过设置这两个属性：

```
/**
* The server's hostname that should be used to make the TCP connection.
* 注释太长，简单说就是主机。这个属性是可选设置的，如果没有设置主机，默认会使用domain
*/
@property (readwrite, copy) NSString *hostName;
 
/**
* The port the xmpp server is running on.
* If you do not explicitly set the port, the default port will be used.
* If you set the port to zero, the default port will be used.
*
* The default port is 5222.
**/
@property (readwrite, assign) UInt16 hostPort;
```
 
#### XMPPStream有XMPPJID类对象作为属性，标识用户，因为我们后续很多操作都需要到myJID：
 
```
@property (readwrite, copy) XMPPJID *myJID;
```
 
#### 而管理用户在线状态的就交由XMPPPresence类了，它同样被作为XMPPStream的属性，组合到XMPPStream中，后续很多关于用户的操作是需要到处理用户状态的：
 
```
/**
* Represents the last sent presence element concerning the presence of myJID on the server.
* In other words, it represents the presence as others see us.
*
* This excludes presence elements sent concerning subscriptions, MUC rooms, etc.
*
* @see resendMyPresence
**/
@property (strong, readonly) XMPPPresence *myPresence;
```
 
#### XMPPStreamDelegate
#### 这个协议是非常关键的，我们的很多主要操作都集中在这个协议的代理回调上。它分为好几种类型的代理API，比如授权的、注册的、安全的等：

```
@protocol XMPPStreamDelegate
@optional
// 将要与服务器连接是回调
- (void)xmppStreamWillConnect:(XMPPStream *)sender;
 
// 当tcp socket已经与远程主机连接上时会回调此代理方法
// 若App要求在后台运行，需要设置XMPPStream's enableBackgroundingOnSocket属性
- (void)xmppStream:(XMPPStream *)sendersocketDidConnect:(GCDAsyncSocket *)socket;
 
// 当TCP与服务器建立连接后会回调此代理方法
- (void)xmppStreamDidStartNegotiation:(XMPPStream *)sender;
 
// TLS传输层协议在将要验证安全设置时会回调
// 参数settings会被传到startTLS
// 此方法可以不实现的，若选择实现它，可以可以在
// 若服务端使用自签名的证书，需要在settings中添加GCDAsyncSocketManuallyEvaluateTrust=YES
//
- (void)xmppStream:(XMPPStream *)senderwillSecureWithSettings:(NSMutableDictionary *)settings;
 
// 上面的方法执行后，下一步就会执行这个代理回调
// 用于在TCP握手时手动验证是否受信任
- (void)xmppStream:(XMPPStream *)senderdidReceiveTrust:(SecTrustRef)trust
                                      completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;
 
// 当stream通过了SSL/TLS的安全验证时，会回调此代理方法
- (void)xmppStreamDidSecure:(XMPPStream *)sender;
 
// 当XML流已经完全打开时（也就是与服务器的连接完成时）会回调此代理方法。此时可以安全地与服务器通信了。
- (void)xmppStreamDidConnect:(XMPPStream *)sender;
 
// 注册新用户成功时的回调
- (void)xmppStreamDidRegister:(XMPPStream *)sender;
 
// 注册新用户失败时的回调
- (void)xmppStream:(XMPPStream *)senderdidNotRegister:(NSXMLElement *)error;
 
// 授权通过时的回调，也就是登录成功的回调
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender;
 
// 授权失败时的回调，也就是登录失败时的回调
- (void)xmppStream:(XMPPStream *)senderdidNotAuthenticate:(NSXMLElement *)error;
 
// 将要绑定JID resource时的回调，这是授权程序的标准部分，当验证JID用户名通过时，下一步就验证resource。若使用标准绑定处理，return nil或者不要实现此方法
- (id <XMPPCustomBinding>)xmppStreamWillBind:(XMPPStream *)sender;
 
// 如果服务器出现resouce冲突而导致不允许resource选择时，会回调此代理方法。返回指定的resource或者返回nil让服务器自动帮助我们来选择。一般不用实现它。
- (NSString *)xmppStream:(XMPPStream *)senderalternativeResourceForConflictingResource:(NSString *)conflictingResource;
 
// 将要发送IQ（消息查询）时的回调
- (XMPPIQ *)xmppStream:(XMPPStream *)senderwillReceiveIQ:(XMPPIQ *)iq;
// 将要接收到消息时的回调
- (XMPPMessage *)xmppStream:(XMPPStream *)senderwillReceiveMessage:(XMPPMessage *)message;
// 将要接收到用户在线状态时的回调
- (XMPPPresence *)xmppStream:(XMPPStream *)senderwillReceivePresence:(XMPPPresence *)presence;
 
/**
* This method is called if any of the xmppStream:willReceiveX: methods filter the incoming stanza.
*
* It may be useful for some extensions to know that something was received,
* even if it was filtered for some reason.
**/
// 当xmppStream:willReceiveX:(也就是前面这三个API回调后)，过滤了stanza，会回调此代理方法。
// 通过实现此代理方法，可以知道被过滤的原因，有一定的帮助。
- (void)xmppStreamDidFilterStanza:(XMPPStream *)sender;
 
// 在接收了IQ（消息查询后）会回调此代理方法
- (BOOL)xmppStream:(XMPPStream *)senderdidReceiveIQ:(XMPPIQ *)iq;
// 在接收了消息后会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidReceiveMessage:(XMPPMessage *)message;
// 在接收了用户在线状态消息后会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidReceivePresence:(XMPPPresence *)presence;
 
// 在接收IQ/messag、presence出错时，会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidReceiveError:(NSXMLElement *)error;
 
// 将要发送IQ（消息查询时）时会回调此代理方法
- (XMPPIQ *)xmppStream:(XMPPStream *)senderwillSendIQ:(XMPPIQ *)iq;
// 在将要发送消息时，会回调此代理方法
- (XMPPMessage *)xmppStream:(XMPPStream *)senderwillSendMessage:(XMPPMessage *)message;
// 在将要发送用户在线状态信息时，会回调此方法
- (XMPPPresence *)xmppStream:(XMPPStream *)senderwillSendPresence:(XMPPPresence *)presence;
 
// 在发送IQ（消息查询）成功后会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidSendIQ:(XMPPIQ *)iq;
// 在发送消息成功后，会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidSendMessage:(XMPPMessage *)message;
// 在发送用户在线状态信息成功后，会回调此方法
- (void)xmppStream:(XMPPStream *)senderdidSendPresence:(XMPPPresence *)presence;
 
// 在发送IQ（消息查询）失败后会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidFailToSendIQ:(XMPPIQ *)iqerror:(NSError *)error;
// 在发送消息失败后，会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidFailToSendMessage:(XMPPMessage *)messageerror:(NSError *)error;
// 在发送用户在线状态失败信息后，会回调此方法
- (void)xmppStream:(XMPPStream *)senderdidFailToSendPresence:(XMPPPresence *)presenceerror:(NSError *)error;
 
// 当修改了JID信息时，会回调此代理方法
- (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream;
 
// 当Stream被告知与服务器断开连接时会回调此代理方法
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender;
 
// 当发送了</stream:stream>节点时，会回调此代理方法
- (void)xmppStreamDidSendClosingStreamStanza:(XMPPStream *)sender;
 
// 连接超时时会回调此代理方法
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender;
 
// 当与服务器断开连接后，会回调此代理方法
- (void)xmppStreamDidDisconnect:(XMPPStream *)senderwithError:(NSError *)error;
 
// p2p类型相关的
- (void)xmppStream:(XMPPStream *)senderdidReceiveP2PFeatures:(NSXMLElement *)streamFeatures;
- (void)xmppStream:(XMPPStream *)senderwillSendP2PFeatures:(NSXMLElement *)streamFeatures;
 
 
- (void)xmppStream:(XMPPStream *)senderdidRegisterModule:(id)module;
- (void)xmppStream:(XMPPStream *)senderwillUnregisterModule:(id)module;
 
// 当发送非XMPP元素节点时，会回调此代理方法。也就是说，如果发送的element不是
// <iq>, <message> 或者 <presence>，那么就会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidSendCustomElement:(NSXMLElement *)element;
// 当接收到非XMPP元素节点时，会回调此代理方法。也就是说，如果接收的element不是
// <iq>, <message> 或者 <presence>，那么就会回调此代理方法
- (void)xmppStream:(XMPPStream *)senderdidReceiveCustomElement:(NSXMLElement *)element;
```
 
#### 到此，也就理解了XMPPStream五五六六了吧！！！
#### XMPPIQ
#### 消息查询（IQ）就是通过此类来处理的了。XMPP给我们提供了IQ方便创建的类，用于快速生成XML数据。若头文件声明如下：
 
```
@interfaceXMPPIQ: XMPPElement
 
// 生成iq
+ (XMPPIQ *)iq;
+ (XMPPIQ *)iqWithType:(NSString *)type;
+ (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jid;
+ (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
+ (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
+ (XMPPIQ *)iqWithType:(NSString *)typeelementID:(NSString *)eid;
+ (XMPPIQ *)iqWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
+ (XMPPIQ *)iqWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
- (id)init;
- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)jid;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
- (id)initWithType:(NSString *)typeelementID:(NSString *)eid;
- (id)initWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
- (id)initWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
// IQ类型，看下面的说明
- (NSString *)type;
 
// 判断type类型
- (BOOL)isGetIQ;
- (BOOL)isSetIQ;
- (BOOL)isResultIQ;
- (BOOL)isErrorIQ;
 
// 当type为get或者set时，这个API是很有用的，用于指定是否要求有响应
- (BOOL)requiresResponse;
 
- (NSXMLElement *)childElement;
- (NSXMLElement *)childErrorElement;
 
@end
```
 
#### IQ是一种请求／响应机制，从一个实体从发送请求，另外一个实体接受请求并进行响应。例如，client在stream的上下文中插入一个元素，向Server请求得到自己的好友列表，Server返回一个，里面是请求的结果。
#### <type></type>有以下类别（可选设置如：<type>get</type>）：
#### get :获取当前域值。类似于http get方法。
#### set :设置或替换get查询的值。类似于http put方法。
#### result :说明成功的响应了先前的查询。类似于http状态码200。
#### error: 查询和响应中出现的错误。
#### 下面是一个IQ例子：
 
```
<iqfrom="huangyibiao@welcome.com/ios"  
    id="xxxxxxx" 
    to="biaoge@welcome.com/ios"  
    type="get"> 
  <queryxmlns="jabber:iq:roster"/> 
</iq> 
```
 
#### XMPPPresence
#### 这个类代表节点，我们通过此类提供的方法来生成XML数据。它代表用户在线状态，它的头文件内容很少的：
 
```
@interfaceXMPPPresence: XMPPElement
 
// Converts an NSXMLElement to an XMPPPresence element in place (no memory allocations or copying)
+ (XMPPPresence *)presenceFromElement:(NSXMLElement *)element;
 
+ (XMPPPresence *)presence;
+ (XMPPPresence *)presenceWithType:(NSString *)type;
// type：用户在线状态，看下面的讲解
// to：接收方的JID
+ (XMPPPresence *)presenceWithType:(NSString *)typeto:(XMPPJID *)to;
 
- (id)init;
- (id)initWithType:(NSString *)type;
 
// type：用户在线状态，看下面的讲解
// to：接收方的JID
- (id)initWithType:(NSString *)typeto:(XMPPJID *)to;
 
- (NSString *)type;
 
- (NSString *)show;
- (NSString *)status;
 
- (int)priority;
 
- (int)intShow;
 
- (BOOL)isErrorPresence;
 
@end
```
 
#### presence用来表明用户的状态，如：online、away、dnd(请勿打扰)等。当改变自己的状态时，就会在stream的上下文中插入一个Presence元素，来表明自身的状态。要想接受presence消息，必须经过一个叫做presence subscription的授权过程。
#### <type></type>有以下类别（可选设置如：<type>subscribe</type>）：
#### subscribe：订阅其他用户的状态
#### probe：请求获取其他用户的状态
#### unavailable：不可用，离线（offline）状态
#### <show></show>节点有以下类别，如<show>dnd</show>：
#### chat：聊天中
#### away：暂时离开
#### xa：eXtend Away，长时间离开
#### dnd：勿打扰
#### <status></status>节点
#### 这个节点表示状态信息，内容比较自由，几乎可以是所有类型的内容。常用来表示用户当前心情，活动，听的歌曲，看的视频，所在的聊天室，访问的网页，玩的游戏等等。
#### <priority></priority>节点
#### 范围-128~127。高优先级的resource能接受发送到bare JID的消息，低优先级的resource不能。优先级为负数的resource不能收到发送到bare JID的消息。
#### 发送一个用户在线状态的例子：
 
```
<presencefrom="alice@wonderland.lit/pda"> 
  <show>dnd</show> 
  <status>浏览器搜索：标哥的技术博客，或者直接访问www.henishuo.com</status> 
</presence> 
```

#### XMPPMessage
#### XMPPMessage是XMPP框架给我们提供的，方便用于生成XML消息的数据，其头文件如下：
 
```
@interfaceXMPPMessage: XMPPElement
 
+ (XMPPMessage *)messageFromElement:(NSXMLElement *)element;
 
+ (XMPPMessage *)message;
+ (XMPPMessage *)messageWithType:(NSString *)type;
+ (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)to;
+ (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
+ (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
+ (XMPPMessage *)messageWithType:(NSString *)typeelementID:(NSString *)eid;
+ (XMPPMessage *)messageWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
+ (XMPPMessage *)messageWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
- (id)init;
- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)to;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
- (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
- (id)initWithType:(NSString *)typeelementID:(NSString *)eid;
- (id)initWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
- (id)initWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
- (NSString *)type;
- (NSString *)subject;
- (NSString *)body;
- (NSString *)bodyForLanguage:(NSString *)language;
- (NSString *)thread;
 
- (void)addSubject:(NSString *)subject;
- (void)addBody:(NSString *)body;
- (void)addBody:(NSString *)bodywithLanguage:(NSString *)language;
- (void)addThread:(NSString *)thread;
 
- (BOOL)isChatMessage;
- (BOOL)isChatMessageWithBody;
- (BOOL)isErrorMessage;
- (BOOL)isMessageWithBody;
 
- (NSError *)errorMessage;
 
@end
```
 
#### message是一种基本 推送 消息方法，它不要求响应。主要用于IM、groupChat、alert和notification之类的应用中。 
#### <type></type>有以下类别（可选设置如：<type> chat</type>）：
#### normal：类似于email，主要特点是不要求响应；
#### chat：类似于qq里的好友即时聊天，主要特点是实时通讯；
#### groupchat：类似于聊天室里的群聊；
#### headline：用于发送alert和notification；
#### error：如果发送message出错，发现错误的实体会用这个类别来通知发送者出错了；
#### <body></body>节点
#### 所要发送的内容就放在body节点下
#### 消息节点的例子：
 
```
<messageto="lily@jabber.org/contact" type="chat"> 
    <body>您好？您的博客名是叫标哥的技术博客吗？地址是http://www.henishuo.com吗？</body>
</message>
```

#### 吧啦吧啦一大堆,其实我是从别人的文章copy来的

> ## 登录
### 登录的流程是这样:
 #### 1.初始化一个xmppStream
 #### 2.连接服务器（成功或者失败）
 #### 3.成功的基础上，服务器验证（成功或者失败）
 #### 4.成功的基础上，发送上线消息
 
 ### 初始化相关类
 ```
 - (XMPPStream *)xmppStream{
    if(!_xmppStream){
        //聊天初始化
        //1.初始化xmppStream，登录和注册的时候都会用到它
        _xmppStream = [[XMPPStream alloc] init];
        //设置服务器地址,这里用的是本地地址（可换成公司具体地址）
        [_xmppStream setHostName:@"192.168.21.202"];
        //设置端口号
        [_xmppStream setHostPort:5222];
    }
    return _xmppStream;
}
 ```
 
 ```
 - (void)loginWithName:(NSString *)userName password:(NSString *)password{
    //标记连接服务器的目的
    self.connectType = XMPPLogin;
    //这里记录用户输入的密码，在登录（注册）的方法里面使用
    self.currentUser.password = password;
    self.currentUser.userName = userName;
    //  创建xmppjid（用户0,  @param NSString 用户名，域名，登录服务器的方式（苹果，安卓等）
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:DoMain resource:Resource];
    self.xmppStream.myJID = jid;
    //连接到服务器
    [self connectToServer];
}

- (void)connectToServer{
    //如果已经存在一个连接或正在连接中，需要将当前的连接断开，然后再开始新的连接
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        [self logout];
    }
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:6.0f error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

#pragma XMPPStream 代理
#pragma mark 连接服务器失败的方法
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    [SVProgressHUD showErrorWithStatus:@"连接服务器超时"];
    NSLog(@"连接服务器失败的方法，请检查网络是否正常");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    [SVProgressHUD showErrorWithStatus:@"连接服务器失败"];
    NSLog(@"didReceiveError");
}

#pragma mark 连接服务器成功的方法
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接服务器成功的方法");
    //登录
    if (self.connectType == XMPPLogin) {
        NSError *error = nil;
        //向服务器发送密码验证 //验证可能失败或者成功
        [sender authenticateWithPassword:self.currentUser.password error:&error];
        if(!error){
            self.currentUser.jid = sender.myJID;
            NSLog(@"登录成功");
        }else{
            NSLog(@"登录失败");
        }
    }
    //注册
    else{
        //向服务器发送一个密码注册（成功或者失败）
        if([sender registerWithPassword:self.currentUser.password error:nil]){
            NSLog(@"注册成功");
        }else{
            NSLog(@"注册失败");
        }
    }
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"xmppStreamDidAuthenticate登录成功");
    _isLogout = NO;
    //发起上线状态
    [self goOnline];
    //发出登录通知成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccess object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"密码不正确%@",error);
    _isLogout = YES;
    [self offline];
    //发出登录通知失败通知
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginFaild object:nil];
}

//发起上线状态给服务器
- (void)goOnline{
    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:@"我现在很忙"]];
    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"xa"]];
    
    [self.xmppStream sendElement:presence];
}
 
 ```
 
 ### 以上就是登录流程,比较暴力直接贴了一堆代码
 
 > ##添加好友
 #### 添加实际是发送一个IQ请求
 ```
 #pragma mark 添加好友
- (void)addFriend:(UserModel *)user{
    if(user){
        //这里的nickname是我对它的备注，并非他的个人资料中得nickname
        [[XMPPManager shareInstanceManager].xmppRoster addUser:user.jid withNickname:user.userName];
    }
}

#pragma mark ===== 好友模块=======
/** 收到出席订阅请求（代表对方想添加自己为好友) */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
    self.pj_newFriend.jid = presence.from;
    
    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",presence.from.bare];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}

 
 ```
 
 > ## XMPPRoster获取好友列表(获取的是在线的好友列表
 #### XMPPRoster 可以处理和好友相关的事：获取好友列表，添加好友，接收好友请求，同意添加好友，拒绝添加好友
 #### XMPPRosterCoreDataStorage用于存储好友(需要知道一些CoreData相关)
 ### 初始化相关类
 ```
 - (XMPPRoster *)xmppRoster{
    if(!_xmppRoster){
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        //关闭自动同步好友列表,在需要拉取好友列表的地方调用fetchRoster方法去拉取
        [_xmppRoster setAutoFetchRoster:NO];
    }
    return _xmppRoster;
}

- (XMPPRosterCoreDataStorage *)xmppRosterCoreDataStorage{
    if(!_xmppRosterCoreDataStorage){
        // 3.好友模块 支持我们管理、同步、申请、删除好友
        _xmppRosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    }
    return _xmppRosterCoreDataStorage;
}
 ```
 #### 在需要拉取在线好友的地方:
 ```
 //好友列表代理
    [[XMPPManager shareInstanceManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //主动拉取好友列表,不过这边拉取的好友是在线好友
    [[XMPPManager shareInstanceManager].xmppRoster fetchRoster];

 ```
 
 #### 以上代码执行后会走一下回调
 ```
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
 * 同步结束
 **/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"获取好友列表结束,此处向外部传值");
    [self loadFreinds];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

 ```
 
 #### 同步sqlite中的好友
 ```
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
 ```
 
 ### 接下来就进入聊天模块了
 > ## 发送文字
 ```
 //发送消息的方法
 /**
 * This method handles sending an XML stanza.
 * If the XMPPStream is not connected, this method does nothing.
**/
- (void)sendElement:(NSXMLElement *)element;
 ```
 
 #### 自己封装消息并且发送
 ```
 //发送文本消息
- (void)sendTextMessage{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_chatUserModel.jid];
    [message addBody:_inputBar.messageContent];
    [message addSubject:TextMessage];
    //自定义文本消息类
    PJContentMessage *contentMessage = [[PJContentMessage alloc] initWithXMPPMessage:message];
    contentMessage.showMessageIn = ShowMessageInRight;
    [self.chatArray addObject:contentMessage];
    [self.tableView reloadData];
    [self tableViewScrollToBottom];
    [[XMPPManager shareInstanceManager].xmppStream sendElement:message];
}
 ```
 
> ## 发送图片
### 发送方式:
#### 1：首先将图片变成2进制（NSData）格式，然后利用Base64将其变为字符串，当文字发送，然后在发送端添加设置其属性，接收端通过判断其属性来判断传过来的到底是啥。如果是图片再用Base64将字符串解成NSData然后转成图片即可。
#### 2：将图片直接转为2进制，然后利用ASI将其上传到服务器，然后发送端发送你图片所在的地址给接收端，然后接收端从此地址下载即可。
#### 关于图片发送：
#### 语音的话首先通过AVAudioRecorder录音，选择好格式(acc,amr)。微信就是用的amr转码。然后剩下的跟图片方案一样

### 图片和音频文件发送的基本思路就是：
#### 先将图片转化成二进制文件，然后将二进制文件进行base64编码，编码后成字符串。在即将发送的message内添加一个子节点，节点的stringValue（节点的值）设置这个编码后的字符串。然后消息发出后取出消息文件的时候，通过messageType 先判断是不是图片信息，如果是图片信息先通过自己之前设置的节点名称，把这个子节点的stringValue取出来，应该是一个base64之后的字符串.

```
//发送图片消息
- (void)sendImageMessage:(UIImage *)image{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_chatUserModel.jid];
    [message addBody:ImageMessage];
    [message addSubject:ImageMessage];
    //自定义图片类
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
```

#### 图片的缓存
```
//这边的图片缓存只是简单的保存到沙盒中并且是在主线程中执行保存必然会造成卡顿,实际中需要对图片进行压缩等操作
+ (void)cacheImage:(NSData *)imageData imageMessage:(PJImageMessage *)imageMessage{
    
    if(!imageData || [NSString isBlankString:imageMessage.imageName]){
        return;
    }
    
    NSString *sandoxPath = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imageDirectoryPath = [sandoxPath stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",[XMPPManager shareInstanceManager].currentUser.userName]];
    
    //创建每个聊天者对应的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:imageDirectoryPath]){
        //目录不存在创建一个
        [fileManager createDirectoryAtPath:imageDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //创建文件路径
    NSString *filePath= [imageDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageMessage.imageName]];
    
    if([imageData writeToFile:filePath atomically:YES]){
        //设置缓存好的图片的本地路径
        imageMessage.localUrl = filePath;
    }
}
```

> ## 发送语音
```
//发送语音消息,PJVoiceMessage为自定义语音类,里面包含了录制好的语音的位置
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
```

#### 收到语音消息后缓存语音
```
//这边的语音缓存只是简单的保存到沙盒中并且是在主线程中执行保存必然会造成卡顿,实际中需要对语音进行压缩等操作
+ (void)cacheVoice:(NSData *)voiceData voiceMessage:(PJVoiceMessage *)voiceMessage{
    
    if(!voiceData || [NSString isBlankString:voiceMessage.voiceName]){
        return;
    }
    
    NSString *sandoxPath = NSHomeDirectory();
    //设置一个语音的存储路径
    NSString *voiceDirectoryPath = [sandoxPath stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@/voice/",[XMPPManager shareInstanceManager].currentUser.userName]];
    
    //创建每个聊天者对应的文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:voiceDirectoryPath]){
        //目录不存在创建一个
        [fileManager createDirectoryAtPath:voiceDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //创建文件路径
    NSString *filePath= [voiceDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aac",voiceMessage.voiceName]];
    
    if([voiceData writeToFile:filePath atomically:YES]){
        //设置缓存好的语音的本地路径
        voiceMessage.localUrl = filePath;
    }
}

```

## 好了,大概就这些,比较基本的,我做的简书地址为:(简书地址)[http://www.jianshu.com/p/c196135efc45]里面有很多BUG不要太介意
 
