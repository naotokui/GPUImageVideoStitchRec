//
//  NTVideoTake.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTVideoTake.h"

@implementation NTVideoTake

- (AVAsset *)videoAsset
{
    return [AVAsset assetWithURL:self.videoPath];
}

- (CGSize) timeRange
{
    return CGSizeMake(self.startAt, self.duration);
}

@end
