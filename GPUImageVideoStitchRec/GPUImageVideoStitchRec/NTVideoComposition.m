//
//  NTVideoComposition.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTVideoComposition.h"
#import <AssetsLibrary/AssetsLibrary.h>

static float kMaxDuration = 20.0;

@implementation NTVideoComposition
{
    NSMutableArray *takes;
    
    // For checking recording duration
    NSDate          *startedAt;
    NSTimer         *timer;
}

- (float) maxDurationAllowed
{
    return  kMaxDuration;
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

- (void) addVideoClip: (NTVideoClip *) take
{
    float duration = [self duration];
    take.startAt = duration;
    [takes addObject: take];
    self.isLastTakeReadyToRemove = NO;
}

- (void) removeLastVideoClip
{
    [takes removeLastObject];
    self.isLastTakeReadyToRemove = NO;
}

- (float) duration
{
    return [self recordedDuration] + [self recordingDuration];
}

- (CGSize) lastVideoClipRange
{
    NTVideoClip *take = [takes lastObject];
    return  take.timeRange;
}

#pragma mark

- (BOOL) canAddVideoClip
{
    return ([self duration] < kMaxDuration);
}

- (void) setRecording: (BOOL) recording
{
    _isRecording = recording;

    if (_isRecording){
        startedAt = [NSDate date];
        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    } else {
        [self timerFired];
        [timer invalidate]; timer = nil;
        startedAt = nil;
    }
}

- (float) recordingDuration
{
    if (!_isRecording) return  0.0;
    else {
        return [startedAt timeIntervalSinceNow] * -1;
    }
}

- (float) recordedDuration
{
    float dur = 0;
    for (NTVideoClip *take in takes){
        dur += take.duration;
    }
    return dur;
}

- (void) timerFired
{
    [self willChangeValueForKey: @"duration"];
    [self didChangeValueForKey: @"duration"];
}

#pragma mark


- (void) concatenateVideosWithCompletionHandler:(void (^)(BOOL))handler
{
    if (self.duration == 0){
        NSLog(@"No video clips to stitch");
        handler(NO);
        return;
    }
    
    
    NSMutableArray *assets = [NSMutableArray array];
    for (NTVideoClip *take in takes){
        [assets addObject: [take videoAsset]];
    }
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTime current = kCMTimeZero;
    NSError *compositionError = nil;
    for(AVAsset *asset in assets) {
        BOOL result = [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                           ofAsset:asset atTime:current error:&compositionError];
        if(!result) {
            handler(NO);
            return;
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
        BOOL success = ([exportSession status] == AVAssetExportSessionStatusCompleted);
        handler(success);
    }];
}


@end
