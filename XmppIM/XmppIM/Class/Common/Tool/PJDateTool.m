//
//  PJDateTool.m
//  XmppIM
//
//  Created by 飘金 on 2017/7/14.
//  Copyright © 2017年 cn.mjbang. All rights reserved.
//

#import "PJDateTool.h"

@interface PJDateTool ()

@property (nonatomic, strong)NSDateFormatter *formatter;

@end

@implementation PJDateTool

+ (instancetype)shareInstance{
    static PJDateTool *dateTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTool = [[PJDateTool alloc] init];
    });
    return dateTool;
}

- (NSString *)currentDate{
    NSDate *date = [NSDate date];
    NSString *dateTime = [self.formatter stringFromDate:date];
    return dateTime;
}

//NSDateFormatter创建比较耗内存,故这边获取时间的方法是实例方法而不是类方法,为的是复用NSDateFormatter
- (NSDateFormatter *)formatter{
    if(!_formatter){
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterMediumStyle];
        [_formatter setTimeStyle:NSDateFormatterShortStyle];
        [_formatter setDateFormat:@"YYYY-MM-dd-hh:mm:ss"];
    }
    return _formatter;
}

@end
