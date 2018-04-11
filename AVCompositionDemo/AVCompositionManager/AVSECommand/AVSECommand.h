//
//  AVSECommand.h
//  VideoComposition
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString* const AVSEEditCommandCompletionNotification;
extern NSString* const AVSEExportCommandCompletionNotification;

@interface AVSECommand : NSObject

@property AVMutableComposition *mutableComposition;
@property AVMutableVideoComposition *mutableVideoComposition;
@property AVMutableAudioMix *mutableAudioMix;
@property CALayer *watermarkLayer;

- (id)initWithComposition:(AVMutableComposition*)composition videoComposition:(AVMutableVideoComposition*)videoComposition audioMix:(AVMutableAudioMix*)audioMix;
- (void)performWithAsset:(AVAsset*)asset;
@end
