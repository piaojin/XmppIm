//
//  NSString+DX.m
//  MJBangProject
//
//  Created by DavidWang on 16/8/1.
//  Copyright © 2016年 X团. All rights reserved.
//

#import "NSString+PJ.h"

@implementation NSString (PJ)

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
