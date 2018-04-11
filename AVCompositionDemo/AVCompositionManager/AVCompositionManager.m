//
//  AVCompositionManager.m
//  AVCompositionDemo
//
//  Created by navy on 2018/4/11.
//  Copyright © 2018 navy. All rights reserved.
//

#import "AVCompositionManager.h"

#import <AVFoundation/AVFoundation.h>
#import "AVAsset+Composition.h"
#import "AVSEExportCommand.h"

@interface AVCompositionManager () {
}
@property CGFloat width;
@property CompositionCompletion completion;
@property AVSEExportCommand *exportCommand;
@end


@implementation AVCompositionManager

- (instancetype)init {
    if (self = [super init]) {
        _width = 320;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(exportCommandCompletionNotificationReceiver:)
                                                     name:AVSEExportCommandCompletionNotification
                                                   object:nil];
    }
    return self;
}

//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    static AVComposeManager * manager = nil;
//    dispatch_once(&onceToken, ^{
//        manager = [AVComposeManager new];
//    });
//    return manager;
//}

//+ (instancetype)sharedInstance {
//    static __weak AVComposeManager *instance;
//    AVComposeManager *strongInstance = instance;
//    @synchronized(self) {
//        if (strongInstance == nil) {
//            strongInstance = [[[self class] alloc] init];
//            instance = strongInstance;
//        }
//    }
//    return strongInstance;
//}

+ (instancetype)sharedInstance {
    //static修饰的是弱引用指针
    static __weak AVCompositionManager *instance;
    AVCompositionManager __block *strongInstance = instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (strongInstance == nil) {
            strongInstance = [AVCompositionManager new];
            instance = strongInstance;
        }
    });
    return strongInstance;
}

- (void)exportCommandCompletionNotificationReceiver:(NSNotification *)notification {
    if ([[notification name] isEqualToString:AVSEExportCommandCompletionNotification]) {
        dispatch_async( dispatch_get_main_queue(), ^{
            [self exportDidEnd];
        });
    }
}

- (void)exportDidEnd {
    self.completion();
}

- (void)composeWithUrls:(NSArray <NSString *>*)urlArr completion:(CompositionCompletion)completion {
    if (completion) {
        self.completion = [completion copy];
    }
    if (urlArr.count == 2) {
        [self loadAssetWithUrlString:urlArr[0] urlStr:urlArr[1]];
    }
}

- (void)loadAssetWithUrlString:(NSString *)urlStr_1 urlStr:(NSString *)urlStr_2 {
    NSArray *assetKeys = @[@"playable", @"composable", @"tracks", @"duration"];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:urlStr_1]];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:urlStr_2]];
    NSArray <AVAsset *>*assets = @[asset1, asset2];
    AVMutableComposition *composition = [AVMutableComposition composition];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    [self loadAsset:asset1
         withAssets:assets
           withKeys:assetKeys
        withTrackID:1
    withComposition:composition
 usingDispatchGroup:dispatchGroup];
    
    [self loadAsset:asset2
         withAssets:assets
           withKeys:assetKeys
        withTrackID:2
    withComposition:composition
 usingDispatchGroup:dispatchGroup];
    
    // Wait until both assets are loaded
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        [self composeWithAssets:assets withComposition:composition];
    });
}

- (void)loadAsset:(AVAsset *)asset
       withAssets:(NSArray <AVAsset *>*)assets
         withKeys:(NSArray *)assetKeys
      withTrackID:(CMPersistentTrackID)trackID
  withComposition:(AVMutableComposition *)composition
usingDispatchGroup:(dispatch_group_t)dispatchGroup {
    dispatch_group_enter(dispatchGroup);
    [asset whenAssetKeys:assetKeys areReadyDo:^{
        [self addVideoAsset:asset withAssets:assets toComposition:composition withTrackID:trackID];
        [self addAudioAsset:asset withAssets:assets toComposition:composition withTrackID:trackID];
        dispatch_group_leave(dispatchGroup);
    }];
}

- (void)composeWithAssets:(NSArray <AVAsset *>*)assets withComposition:(AVMutableComposition *)composition  {
    AVAssetTrack *oneVideoTrack = assets[0].firstVideoTrack;
    AVAssetTrack *twoVideoTrack = assets[1].firstVideoTrack;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    //视频渲染大小为4：3
    videoComposition.renderSize = CGSizeMake(_width, _width * 3 / 4);
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / twoVideoTrack.nominalFrameRate, oneVideoTrack.naturalTimeScale);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = [composition.tracks.firstObject timeRange];
    
    AVMutableVideoCompositionLayerInstruction *oneLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
    [oneLayerInstruction setTransform:CGAffineTransformMakeScale(_width /2/ oneVideoTrack.naturalSize.width, _width *3 / 4 / oneVideoTrack.naturalSize.height)
                               atTime:kCMTimeZero];
    oneLayerInstruction.trackID = 1;
    
    AVMutableVideoCompositionLayerInstruction *twoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
    //    [twoLayerInstruction setTransform:CGAffineTransformMakeTranslation(_width / 2, 0)
    //                               atTime:kCMTimeZero];
    [twoLayerInstruction setTransform:CGAffineTransformMakeTranslation(1, 1)
                               atTime:kCMTimeZero];
    twoLayerInstruction.trackID = 2;
    
    //左右画面
    instruction.layerInstructions = @[oneLayerInstruction, twoLayerInstruction];
    videoComposition.instructions = @[instruction];
    
    _exportCommand = [[AVSEExportCommand alloc] initWithComposition:composition
                                                   videoComposition:videoComposition
                                                           audioMix:nil];
    [_exportCommand performWithAsset:nil];
}

- (void)addVideoAsset:(AVAsset *)asset
           withAssets:(NSArray *)assets
        toComposition:(AVMutableComposition *)composition
          withTrackID:(CMPersistentTrackID)trackID {
    AVAsset *asset1 = assets[0];
    AVAsset *asset2 = assets[1];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:trackID];
    CMTimeRange timeRange;
    if (CMTimeGetSeconds(asset1.duration) > CMTimeGetSeconds(asset2.duration)) {
        timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,asset2.duration);
    } else {
        timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,asset1.duration);
    }
    AVAssetTrack *assetVideoTrack = asset.firstVideoTrack;
    [videoTrack insertTimeRange:timeRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
}

- (void)addAudioAsset:(AVAsset *)asset
           withAssets:(NSArray *)assets
        toComposition:(AVMutableComposition *)composition
          withTrackID:(CMPersistentTrackID)trackID {
    AVAsset *asset1 = assets[0];
    AVAsset *asset2 = assets[1];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:trackID];
    CMTimeRange timeRange;
    if (CMTimeGetSeconds(asset1.duration) > CMTimeGetSeconds(asset2.duration)) {
        timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,asset2.duration);
    } else {
        timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,asset1.duration);
    }
    AVAssetTrack *assetAudioTrack = asset.firstAudioTrack;
    [audioTrack insertTimeRange:timeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
}

@end
