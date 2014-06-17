//
//  NTRecProgressView.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTRecProgressView.h"

@implementation NTRecProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.25);
    CGContextFillRect(context, rect);
    
    // Fixed
    float maxDuration = 20.0;
    float w         = self.frame.size.width;
    float h         = self.frame.size.height;
    
    if (!self.composition.isLastTakeReadyToRemove){
        float length    = [self.composition recordedDuration] / maxDuration * w;
        CGRect fixed    = CGRectMake(0, 0, length, h);
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, fixed);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);

        float addedDuration     = [self.composition recordingDuration];
        float addedLength       = addedDuration / maxDuration * w;
        CGRect added            = CGRectMake(length, 0, addedLength, h);
        CGContextFillRect(context, added);
    } else {
        CGSize range = [self.composition lastVideoClipRange];
        float addedAt           = range.width   / maxDuration * w;
        float addedLength       = range.height / maxDuration * w;
        
        CGRect fixed    = CGRectMake(0, 0, addedAt, h);
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, fixed);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
        
        CGRect added            = CGRectMake(addedAt, 0, addedLength, h);
        CGContextFillRect(context, added);
    }
}

- (void) setComposition:(NTVideoComposition *)composition
{
    _composition = composition;
    
    if (composition){
        [composition addObserver: self forKeyPath: @"isLastTakeReadyToRemove" options: NSKeyValueObservingOptionNew context: nil];
        [composition addObserver: self forKeyPath:@"duration" options: NSKeyValueObservingOptionInitial context: nil];

    } else {
        [composition removeObserver: self forKeyPath: @"isLastTakeReadyToRemove"];
        [composition removeObserver: self forKeyPath: @"duration"];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.composition == object){
        if ( [keyPath isEqualToString: @"isLastTakeReadyToRemove"] || [keyPath isEqualToString: @"duration"]){
            [self setNeedsDisplay];
        }
    }
}

@end
