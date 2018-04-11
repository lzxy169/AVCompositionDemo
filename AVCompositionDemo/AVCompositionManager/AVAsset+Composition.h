//
//  AVAsset+Composition.h
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@interface AVAsset (Composition)
- (AVAssetTrack *)firstVideoTrack;
- (AVAssetTrack *)firstAudioTrack;
- (void)whenAssetKeys:(NSArray *)assetKeys areReadyDo:(void (^)(void))block;
@end
