//
//  MediaViewController.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "MediaViewController.h"
#import "UploadViewController.h"
#import "AppDelegate.h"

@interface MediaViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIImagePickerController *pickerController;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *recordVideoView;

- (void)stopRecording;
- (void)addWatermarkForMovieFile:(NSURL*)url;
- (NSString*)tempFileString;
- (NSURL *)tempFileURL;

@end

@implementation MediaViewController
@synthesize appDelegate = _appDelegate;
@synthesize pickerController = _pickerController;
@synthesize recordVideoView = _recordVideoView;
@synthesize recordNewVideoButton = _recordNewVideoButton;
@synthesize presentUserRollButton = _presentUserRollButton;
@synthesize chooseExistingVideoButton = _chooseExistingVideoButton;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize session = _session;


#pragma mark - Memory Management Methods
- (void)dealloc
{
    self.recordNewVideoButton = nil;
    self.chooseExistingVideoButton = nil;
    self.presentUserRollButton = nil;
}

#pragma mark - Initialization Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Record";
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
   
}


#pragma mark - Public Methods
- (IBAction)recordVideoButtonAction:(id)sender
{

    DLog(@"Recording New Video");
    
    // Change Button
    [self.recordNewVideoButton setImage:[UIImage imageNamed:@"cameraOn"] forState:UIControlStateNormal];
    [self.recordNewVideoButton removeTarget:self action:@selector(recordVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordNewVideoButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    
    // Initialize AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    
    // Configure AVCaptureSession
    [self.session beginConfiguration];
    
    // Add Device
    AVCaptureDevice *device =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [self.session addInput:deviceInput];
    
    // Add Still Image Output
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:stillImageOutput];

    // Add Video File Output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:_movieFileOutput];

    [self.session commitConfiguration];

    // Add Video Layer
    CGRect videoCaptureFrame = CGRectMake(0.0f, -10.0f, 320.0f, 436.0f);
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [captureVideoPreviewLayer setFrame:videoCaptureFrame];
    [captureVideoPreviewLayer setMasksToBounds:YES];
    
    // Add view
    self.recordVideoView = [[UIView alloc] initWithFrame:videoCaptureFrame];
    [_recordVideoView.layer addSublayer:captureVideoPreviewLayer];
    [self.view addSubview:_recordVideoView];
    
    // Begin AVCaptureSession
    [self.session startRunning];
    
    // Beign Recording
    [self.movieFileOutput startRecordingToOutputFileURL:[self tempFileURL]
                                      recordingDelegate:self];

}

- (IBAction)chooseExistingVideoButtonAction:(id)sender
{
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.delegate = self;
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
    self.pickerController.allowsEditing = NO;
    self.pickerController.wantsFullScreenLayout = YES;

    [self presentViewController:_pickerController animated:YES completion:nil];
}

- (void)presentUserRollButtonAction:(id)sender
{
    
}

#pragma mark - Private Methods
- (void)stopRecording
{
    // Stop recording
    [self.movieFileOutput stopRecording];
    [self.session stopRunning];
    self.movieFileOutput = nil;
    self.session = nil;
    [self.recordVideoView removeFromSuperview];
    
    // Change Button
    [self.recordNewVideoButton setImage:[UIImage imageNamed:@"cameraOff"] forState:UIControlStateNormal];
    [self.recordNewVideoButton removeTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.recordNewVideoButton addTarget:self action:@selector(recordVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addWatermarkForMovieFile:(NSURL *)url
{
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:url options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:clipVideoTrack
                                    atTime:kCMTimeZero error:nil];
    
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    UIImage *myImage = [UIImage imageNamed:@"watermark.png"];
    CALayer *aLayer = [CALayer layer];
    aLayer.contents = (id)myImage.CGImage;
    aLayer.frame = CGRectMake(1600, 10, 300, 112);
    
    CGSize videoSize = [clipVideoTrack naturalSize];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];

    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    assetExport.videoComposition = videoComp;
    
    NSString *videoName = [self tempFileString];
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = exportUrl;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {

         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         if ( [library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportUrl] ) {
             [library writeVideoAtPathToSavedPhotosAlbum:exportUrl
                                         completionBlock:^(NSURL *assetURL, NSError *error){
                                             
                                             DLog(@"Added Watermark");
//                                             UploadViewController *uploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
//                                             [self.pickerController pushViewController:uploadViewController animated:YES];
                                         }];
         }
         
     }       
     ];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate Methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self addWatermarkForMovieFile:outputFileURL];
}

#pragma mark - UIImagePickerOrientation Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self addWatermarkForMovieFile:[NSURL URLWithString:UIImagePickerControllerMediaURL]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Setters and Getters
- (NSString *)tempFileString
{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *unixTime = [NSString stringWithFormat:@"%0.0f", time];
    NSString *outputString = [[NSString alloc] initWithFormat:@"%@.mov", unixTime];
    
    return outputString;
}

- (NSURL *)tempFileURL
{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *unixTime = [NSString stringWithFormat:@"%0.0f", time];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@.mov", NSTemporaryDirectory(), unixTime];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    
    return outputURL;
}

@end