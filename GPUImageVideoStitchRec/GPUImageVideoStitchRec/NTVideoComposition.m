//
//  NTVideoComposition.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTVideoComposition.h"

@implementation NTVideoComposition
{
    NSMutableArray *takes;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        takes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"composition contains %ld takes", [takes count]];
}

- (void) addTake: (NTVideoTake *) take
{
    float duration = [self duration];
    take.startAt = duration;
    [takes addObject: take];
}

- (void) removeLastTake
{
    [takes removeLastObject];
}

- (float) duration
{
    float dur = 0;
    for (NTVideoTake *take in takes){
        dur += take.duration;
    }
    return dur;
}

- (CGSize) lastTakeRange
{
    NTVideoTake *take = [takes lastObject];
    return  take.timeRange;
}

- (void) concatenateVideos
{
    NSMutableArray *assets = [NSMutableArray array];
    for (NTVideoTake *take in takes){
        [assets addObject: [take videoAsset]];
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTime current = kCMTimeZero;
    NSError *compositionError = nil;
    for(AVAsset *asset in assets) {
        BOOL result = [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                           ofAsset:asset
                                            atTime:current
                                             error:&compositionError];
        if(!result) {
            if(compositionError) {
                // manage the composition error case
            }
        } else {
            current = CMTimeAdd(current, [asset duration]);
        }
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    AVAssetExportSession *exportSession;
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    } else if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    } else if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent: @"output.mp4"];
    unlink([outputURL UTF8String]);
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"trim completed");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"trim failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"trim canceled");
                break;
            default:
                break;
        }
    }];
}



@end
