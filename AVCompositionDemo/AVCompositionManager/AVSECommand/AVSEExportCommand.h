//
//  AVSEExportCommand.h
//  VideoComposition
//

#import "AVSECommand.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVSEExportCommand : AVSECommand

@property AVAssetExportSession *exportSession;

@end
