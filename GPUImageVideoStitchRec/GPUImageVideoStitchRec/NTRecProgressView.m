//
//  NTRecProgressView.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTRecProgressView.h"

@implementation NTRecProgressView
{
    BOOL    isRecording;
    NSTimer *timer;
    NSDate  *startedAt;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    
    if (isRecording){
        float length    = self.composition.duration / maxDuration * w;
        CGRect fixed    = CGRectMake(0, 0, length, h);
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, fixed);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);

        float addedDuration     = [startedAt timeIntervalSinceNow] * -1;
        float addedLength       = addedDuration / maxDuration * w;
        CGRect added            = CGRectMake(length, 0, addedLength, h);
        CGContextFillRect(context, added);
    } else {
        CGSize range = [self.composition lastTakeRange];
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

- (void) startRecording
{
    isRecording = YES;
    startedAt = [NSDate date];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void) stopRecroding
{
    isRecording = NO;
    
    startedAt = nil;
    [timer invalidate];
    timer = nil;
    
    [self setNeedsDisplay];
}

- (void) timerFired
{
    [self setNeedsDisplay];
}

@end
