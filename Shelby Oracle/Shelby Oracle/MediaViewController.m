//
//  MediaViewController.m
//  Shelby Oracle
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
@property (strong, nonatomic) UIView *recordView;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIButton *stopRecordingButton;

- (void)stopRecording;
- (NSURL *)tempFileURL;

@end

@implementation MediaViewController
@synthesize appDelegate = _appDelegate;
@synthesize pickerController = _pickerController;
@synthesize recordView = _recordView;
@synthesize recordVideoButton = _recordVideoButton;
@synthesize chooseVideoButton = _chooseVideoButton;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize session = _session;
@synthesize stopRecordingButton = _stopRecordingButton;

#pragma mark - Memory Management Methods
- (void)dealloc
{
    self.recordVideoButton = nil;
    self.chooseVideoButton = nil;
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.recordView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.recordView.layer setMasksToBounds:YES];
    [self.view addSubview:_recordView];
    
    
    // Configure AVCaptureSession
    [self.session beginConfiguration];
    
    AVCaptureDevice *device =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [self.session addInput:deviceInput];
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:stillImageOutput];
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session addOutput:_movieFileOutput];
    
    [self.session commitConfiguration];

    // Begin AVCaptureSession
    [self.session startRunning];
    
    // Beign Recording
    [self.movieFileOutput startRecordingToOutputFileURL:[self tempFileURL]
                                      recordingDelegate:self];
    
    
    // Add Recording Button
    self.stopRecordingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.stopRecordingButton setFrame:CGRectMake(75.0f, 250.0f, 150.0f, 40.0f)];
    [self.stopRecordingButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    [self.stopRecordingButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopRecordingButton];

}

- (IBAction)chooseVideoButtonAction:(id)sender
{
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.delegate = self;
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
    self.pickerController.allowsEditing = NO;
    self.pickerController.wantsFullScreenLayout = YES;

    [self presentViewController:_pickerController animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)stopRecording
{
    [self.movieFileOutput stopRecording];
    [self.session stopRunning];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate Methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ( [library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL] ) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){
                                    
                                        // Do nothing
                                        
                                    }];
    } else {
    // Cannot save data
    }
}

#pragma mark - UIImagePickerOrientation Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    DLog(@"%@", info);
    // First, initialize and push shareViewController on UIImageController (which is a subclass of UInavigationController)
    UploadViewController *uploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
    [self.pickerController pushViewController:uploadViewController animated:YES];
    
    // Pass video from pickerController to uploadViewController
//    UIImagePickerControllerMediaURL
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Setters and Getters
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