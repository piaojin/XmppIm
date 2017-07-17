//
//  PJCacheManager.h
//  MJBDesign
//
//  Created by piaojin on 16/12/14.
//  Copyright © 2016年 piaojin. All rights reserved.
//

#import <Foundation/Foundation.h>
//清除缓存成功通知
#define ClearCacheSuccess @"ClearCacheSuccess"

@class PJImageMessage,PJVoiceMessage;
@interface PJCacheManager : NSObject

+ (void)cacheData:(id)data Key:(NSString *)key;

+ (id)getCancheDataForKey:(NSString *)key;

// 显示缓存大小
+(NSString *)cacheSize;

// 清理缓存
+ (void)clearCacheFile;

//这边的图片缓存只是简单的保存到沙盒中并且是在主线程中执行保存必然会造成卡顿,实际中需要对图片进行压缩等操作
+ (void)cacheImage:(NSData *)image imageMessage:(PJImageMessage *)imageMessage;

+ (void)cacheVoice:(NSData *)voiceData voiceMessage:(PJVoiceMessage *)voiceMessage;

+ (NSString *)imageCachePath:(NSString *)imageName;

//语音保存路径
+ (NSString *)voiceCachePath:(NSString *)voiceName;

@end
