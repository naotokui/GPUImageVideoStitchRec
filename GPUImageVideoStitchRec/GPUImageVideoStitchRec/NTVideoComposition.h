//
//  NTVideoComposition.h
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTVideoClip.h"

@interface NTVideoComposition : NSObject

@property (nonatomic, readonly) float duration;
@property (nonatomic, setter=setRecording:) BOOL  isRecording;
@property (nonatomic) BOOL  isLastTakeReadyToRemove;

- (BOOL) canAddVideoClip;

- (void) addVideoClip: (NTVideoClip *) take;
- (void) concatenateVideosWithCompletionHandler:(void (^)(AVAssetExportSessionStatus))handler;

- (void) removeLastVideoClip;
- (CGSize) lastVideoClipRange;

- (float) recordingDuration;
- (float) recordedDuration;

- (float) maxDurationAllowed;

@end
