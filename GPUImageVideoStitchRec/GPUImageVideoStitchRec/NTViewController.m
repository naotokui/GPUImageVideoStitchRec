//
//  NTViewController.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NTVideoTake.h"
#import "NTVideoComposition.h"
#import "NTRecProgressView.h"

@interface NTViewController ()

@end

@implementation NTViewController{
    GPUImageVideoCamera     *videoCamera;
    GPUImageView            *videoView;
    GPUImageMovieWriter     *movieWriter;
    NTRecProgressView       *progressView;
    
    NTVideoComposition      *composition;
    NTVideoTake             *videoTake;
    NSURL *movieURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Camera
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    // Preview view
    videoView = [[GPUImageView alloc] initWithFrame: self.view.frame];
    videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview: videoView atIndex: 0];
    
    //
    progressView = [[NTRecProgressView alloc] initWithFrame: CGRectMake(0, 0, 320, 60)];
    [videoView addSubview: progressView];
    
    // Record Settings
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    movieURL        = [NSURL fileURLWithPath:pathToMovie];
    movieWriter     = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    
    
    // Tap Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    [videoView addGestureRecognizer: gesture];
    
    // Setting
    [videoCamera addTarget: videoView];
    [videoCamera startCameraCapture];
    
    // Video composition
    composition     = [[NTVideoComposition alloc] init];
    progressView.composition = composition;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void) startRecording
{
    [self doesStartRecording];
    NSLog(@"Started");
}

- (void) doesStartRecording
{
    // Record Settings
    NSString *path = [NSString stringWithFormat: @"Documents/Movie_%ld.m4v", random()];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:path];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    movieURL        = [NSURL fileURLWithPath:pathToMovie];
    movieWriter     = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
 
    videoTake = [[NTVideoTake alloc] init];
    videoTake.videoPath = movieURL;
    [composition addTake: videoTake];

    [videoCamera addTarget: movieWriter];
    videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
    
    [progressView startRecording];
}

- (void) pauseRecording
{
    NSLog(@"Paused");

    [videoCamera removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    
    float duration          = CMTimeGetSeconds(movieWriter.duration);
    videoTake.duration    = duration;
    
    [movieWriter finishRecordingWithCompletionHandler:^{

    }];
    [progressView setNeedsDisplay];
    [progressView stopRecroding];
}

- (void) longPressGestureRecognized:(UILongPressGestureRecognizer *) gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self startRecording];
            break;
        case UIGestureRecognizerStateEnded:
            [self pauseRecording];
            break;
        default:
            break;
    }
}

- (IBAction) removeLastTake:(id)sender
{
    [composition removeLastTake];
    [progressView setNeedsDisplay];
}

- (IBAction) stopRecording:(id)sender
{
//    [videoCamera removeTarget:movieWriter];
//    videoCamera.audioEncodingTarget = nil;
    [composition concatenateVideos];
    
//    [movieWriter finishRecordingWithCompletionHandler:^{
//        [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
//            if (error == nil) {
//                NSLog(@"Movie saved");
//            } else {
//                NSLog(@"Error %@", error);
//            }
//        }];
//        
//    }];
}

@end
