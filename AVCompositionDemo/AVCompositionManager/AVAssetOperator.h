//
//  AVAssetOperator.h
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVAssetOperator : NSObject

- (instancetype)initWithFolderName:(NSString *)folderName;

- (void)saveImagePath:(NSString *)imagePath;

- (void)saveVideoPath:(NSString *)videoPath;

- (void)deleteFile:(NSString *)filePath;

@end
