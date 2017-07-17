//
//  PJCancheManager.m
//  MJBDesign
//
//  Created by piaojin on 16/12/14.
//  Copyright © 2016年 piaojin. All rights reserved.
//

#import "PJCacheManager.h"
#import "PJImageMessage.h"
#import "PJVoiceMessage.h"

@implementation PJCacheManager

+ (void)cacheData:(id)data Key:(NSString *)key{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:key];
        [userDefaults synchronize];
    });
}

+ (id)getCancheDataForKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:key];
}

// 显示缓存大小
+(NSString *)cacheSize{
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    float size=[self folderSizeAtPath:cachPath];
    return [NSString stringWithFormat:@"%0.1fM",size];
}

//1:首先我们计算一下 单个文件的大小
+ ( long long ) fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize ];
    }
    return 0 ;
}

//2:遍历文件夹获得文件夹大小，返回多少 M（提示：你可以在工程界设置（)m）
+ ( float ) folderSizeAtPath:( NSString *) folderPath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if (![manager fileExistsAtPath :folderPath]) return 0 ;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
    NSString * fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
        folderSize += [ self fileSizeAtPath :fileAbsolutePath];
    }
    return folderSize/( 1024.0 * 1024.0 );
}

// 清理缓存
+ (void)clearCacheFile{
    NSLog(@"清理缓存");
    NSString * cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) firstObject ];
    NSArray * files = [[ NSFileManager defaultManager ] subpathsAtPath :cachPath];
    NSLog ( @"cachpath = %@" , cachPath);
    for ( NSString * p in files) {
        NSError * error = nil ;
        NSString * path = [cachPath stringByAppendingPathComponent :p];
        if ([[ NSFileManager defaultManager ] fileExistsAtPath :path]) {
            [[ NSFileManager defaultManager ] removeItemAtPath :path error :&error];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ClearCacheSuccess object:nil];
}

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

//图片缓存路径
+ (NSString *)imageCachePath:(NSString *)imageName{
    return [[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",[XMPPManager shareInstanceManager].currentUser.userName]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]];
}

//语音保存路径
+ (NSString *)voiceCachePath:(NSString *)voiceName{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *voiceDirectory = [NSString stringWithFormat:@"%@/piaojin/voice/",docDir];
    NSString *voicePath = [NSString stringWithFormat:@"%@%@.aac",voiceDirectory,voiceName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:voiceDirectory]){
        //目录不存在创建一个
        [fileManager createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return voicePath;
}

@end
