//
//  Header.h
//  XmppIM
//
//  Created by 飘金 on 2017/7/6.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import "SVProgressHUD.h"
#import "XMPPManager.h"
#import "NSString+PJ.h"
#import "PJConst.h"

#define WeakSelf __weak typeof(self) weakSelf = self;

//屏幕物理高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//屏幕物理宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define PJScale(scale) scale * ScreenHeight / 568.0

#define RGBAColor(r, g, b) [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:1.f]

#endif /* Header_h */
