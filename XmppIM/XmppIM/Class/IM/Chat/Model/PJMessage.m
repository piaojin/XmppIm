//
//  PJMessage.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/11.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJMessage.h"

@implementation PJMessage

- (CGFloat)rowH{
    if(_rowH <= 0){
        CGFloat tempmessageContentViewH = self.messageContentSize.height + 2 * M;
        if(tempmessageContentViewH <= AvatarH){
            _rowH = AvatarH + 2 * M;
        }else{
            _rowH = tempmessageContentViewH + 2 * M;
        }
    }
    return _rowH;
}

+ (PJMessage *)dealWithMessage:(XMPPMessage *)xmppMessage{
    return [[PJMessage alloc] init];
}

@end
