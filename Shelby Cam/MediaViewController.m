//
//  MediaViewController.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "MediaViewController.h"
#import "UploadViewController.h"
#import "ProcessingVideoView.h"

@interface MediaViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIImagePickerController *pickerController;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) UIView *recordVideoView;
@property (strong, nonatomic) ProcessingVideoView *processingVideoView;
@property (strong, nonatomic) UITapGestureRecognizer *startRecordingRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *stopRecordingRecognizer;

- (void)startRecording;
- (void)stopRecording;
- (void)addWatermarkForMovieFile:(NSURL*)url;
- (NSString*)tempFileString;
- (NSURL *)tempFileURL;

@end

@implementation MediaViewController
@synthesize appDelegate = _appDelegate;
@synthesize pickerController = _pickerController;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize recordVideoView = _recordVideoView;
@synthesize processingVideoView = _processingVideoView;
@synthesize startRecordingRecognizer = _startRecordingRecognizer;
@synthesize stopRecordingRecognizer = _stopRecordingRecognizer;
@synthesize tapToStartImageView = _tapToStartImageView;
@synthesize toggleLightButton = _toggleLightButton;
@synthesize flipCameraButton = _flipCameraButton;
@synthesize settingsButton = _settingsButton;
@synthesize chooseExistingVideoButton = _chooseExistingVideoButton;
@synthesize recordNewVideoButton = _recordNewVideoButton;
@synthesize presentUserRollButton = _presentUserRollButton;

#pragma mark - Memory Management Methods
- (void)dealloc
{
    self.tapToStartImageView = nil;
    self.toggleLightButton = nil;
    self.flipCameraButton = nil;
    self.settingsButton = nil;
    self.chooseExistingVideoButton = nil;
    self.videoDevice = nil;
    self.recordNewVideoButton = nil;
    self.presentUserRollButton = nil;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Add TapGestureRecognizer to allow for recording to begin
    self.startRecordingRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordVideoButtonAction:)];
    [self.startRecordingRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:_startRecordingRecognizer];
    
    // If navigationBar isn't hidden, hide it.
    if ( NO == self.navigationController.navigationBarHidden ) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
}

- (IBAction)toggleLightButtonAction:(id)sender
{
    
    if ( ![self videoDevice] ) self.videoDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ( self.videoDevice.torchMode == AVCaptureTorchModeOn ) { // If light/torch is on
        
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
        [self.videoDevice setFlashMode:AVCaptureFlashModeOff];
        [self.videoDevice unlockForConfiguration];
        
        [self.toggleLightButton setImage:[UIImage imageNamed:@"lightOff"] forState:UIControlStateNormal];
        
    } else { // If light/torch is off
        
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
        [self.videoDevice unlockForConfiguration];
        
        [self.toggleLightButton setImage:[UIImage imageNamed:@"lightOn"] forState:UIControlStateNormal];

    }

}

- (IBAction)flipCameraButtonAction:(id)sender
{
    DLog(@"%@", [AVCaptureDevice devices]);
}

- (IBAction)settingsButtonAction:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Logout of Shelby Cam?"
                                                             delegate:self
                                                    cancelButtonTitle:@"NO"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil, nil];
    
    [actionSheet showInView:self.view];
    
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

#pragma mark - Public Methods
- (IBAction)recordVideoButtonAction:(id)sender
{

    [self startRecording];
}

- (void)presentUserRollButtonAction:(id)sender
{
    // Present Rolls Modally
}

#pragma mark - Private Methods
- (void)startRecording
{
    DLog(@"Began Recording New Video");
    
    // Change Button
    [self.recordNewVideoButton setImage:[UIImage imageNamed:@"cameraOn"] forState:UIControlStateNormal];
    [self.recordNewVideoButton removeTarget:self action:@selector(recordVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordNewVideoButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    
    // Add TapGestureRecognizer to allow for recording to end
    [self.view removeGestureRecognizer:_startRecordingRecognizer];
    self.stopRecordingRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopRecording)];
    [self.stopRecordingRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:_stopRecordingRecognizer];
    
    // Initialize AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    
    // Configure AVCaptureSession
    [self.session beginConfiguration];
    
    // Add Video Input from Device
    if ( ![self videoDevice] ) self.videoDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:nil];
    [self.session addInput:videoDeviceInput];
    
    // Add Audio Input from Device
    AVCaptureDevice *audioDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    [self.session addInput:audioDeviceInput];
    
    // Add Still Image Output
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:stillImageOutput];
    
    // Add Video File Output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:_movieFileOutput];
    
    // Add Audio File Output
    AVCaptureAudioDataOutput * audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.session addOutput:audioOutput];
    dispatch_queue_t audioQueue = dispatch_queue_create("MY QUEUE", NULL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    
    [self.session commitConfiguration];
    
    // Add Video Layer
    CGRect videoCaptureFrame = CGRectMake(0.0f, 20.0f, 320.0f, 376.0f);
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

- (void)stopRecording
{
    
    // Stop recording
    [self.movieFileOutput stopRecording];
    [self.session stopRunning];

    DLog(@"Ended Recording New Video");

    // Turn of flash/torch if it's on
    if ( self.videoDevice.torchMode == AVCaptureTorchModeOn ) [self toggleLightButtonAction:self];
    
    // Processing Screen
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProcessingVideoView" owner:self options:nil];
    self.processingVideoView = [nib objectAtIndex:0];
    [self.processingVideoView.indicator startAnimating];
    [self.processingVideoView setAlpha:0.67f];
    [self.view addSubview:_processingVideoView];

    // Change Button
    [self.recordNewVideoButton setImage:[UIImage imageNamed:@"cameraOff"] forState:UIControlStateNormal];
    [self.recordNewVideoButton removeTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.recordNewVideoButton addTarget:self action:@selector(recordVideoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Remove Recognizer
    [self.view removeGestureRecognizer:_stopRecordingRecognizer];
    
    // Disable Interaction
    [self.view setUserInteractionEnabled:NO];
    
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
                                             
                                             DLog(@"Finished Processing Video");
                                             
                                             [self.processingVideoView.indicator stopAnimating];
                                             [UIView animateWithDuration:1.0f animations:^{
                                                 [self.processingVideoView setAlpha:0.0f];
                                             } completion:^(BOOL finished) {
                                                 
                                                 // Re-enable Interaction
                                                 [self.view setUserInteractionEnabled:YES];
                                                 
                                                 // Add TapGestureRecognizer to allow for recording to begin (next time user decides to tap)
                                                 self.startRecordingRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordVideoButtonAction:)];
                                                 [self.startRecordingRecognizer setNumberOfTapsRequired:1];
                                                 [self.view addGestureRecognizer:_startRecordingRecognizer];
                                                 
                                                 // Remove views
                                                 [self.recordVideoView removeFromSuperview];
                                                 [self.processingVideoView removeFromSuperview];
                                                 
                                                 // Release AV objects
                                                 self.movieFileOutput = nil;
                                                 self.session = nil;
                                                 
                                                 // Push Upload ViewController
                                                 UploadViewController *uploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
                                                 [self.navigationController pushViewController:uploadViewController animated:YES];
                                                 
                                                 
                                             }];
                                             
                                            
                                         }];
         }
         
     }       
     ];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( 1 == buttonIndex ) {
        
        [self.appDelegate logout];
        
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate Methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self addWatermarkForMovieFile:outputFileURL];
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
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