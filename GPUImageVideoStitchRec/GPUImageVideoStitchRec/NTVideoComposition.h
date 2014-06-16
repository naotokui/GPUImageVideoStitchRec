//
//  NTVideoComposition.h
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTVideoTake.h"

@interface NTVideoComposition : NSObject

@property (nonatomic, readonly) float duration;

- (void) addTake: (NTVideoTake *) take;
- (void) concatenateVideos;

- (void) removeLastTake;
- (CGSize) lastTakeRange;

@end
