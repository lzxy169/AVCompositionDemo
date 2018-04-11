//
//  AVAsset+Composition.m
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//

#import "AVAsset+Composition.h"

@implementation AVAsset (Composition)

- (AVAssetTrack *)firstVideoTrack {
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    return [tracks firstObject];
}

- (AVAssetTrack *)firstAudioTrack {
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeAudio];
    return [tracks firstObject];
}

- (void)whenAssetKeys:(NSArray *)assetKeys areReadyDo:(void (^)(void))block {
    [self loadValuesAsynchronouslyForKeys:assetKeys completionHandler:^{
        NSMutableArray *pendingKeys;
        for (NSString *key in assetKeys) {
            switch ([self statusOfValueForKey:key error:nil]) {
                case AVKeyValueStatusLoaded:
                case AVKeyValueStatusFailed:
                    break;
                default:
                    if (pendingKeys ==  nil) {
                        pendingKeys = [NSMutableArray array];
                    }
                    [pendingKeys addObject:key];
            }
        }
        
        if (pendingKeys == nil) {
            block();
        } else {
            [self whenAssetKeys:pendingKeys areReadyDo:block];
        }
    }];
}

@end
