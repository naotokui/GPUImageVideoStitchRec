//
//  NTViewController.m
//  GPUImageVideoStitchRec
//
//  Created by Nao Tokui on 6/16/14.
//  Copyright (c) 2014 Nao Tokui. All rights reserved.
//

#import "NTViewController.h"

@interface NTViewController ()

@end

@implementation NTViewController{
    GPUImageVideoCamera     *videoCamera;
    GPUImageView            *videoView;
    GPUImageMovieWriter     *movieWriter;
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
    [self.view addSubview: videoView];
    
    // Record Settings
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    
    
    // Tap Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    [videoView addGestureRecognizer: gesture];
    
    // Setting
    [videoCamera addTarget: videoView];
    [videoCamera startCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void) startRecording
{
    videoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
}

- (void) pauseRecording
{
    [videoCamera pauseCameraCapture];
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

@end
