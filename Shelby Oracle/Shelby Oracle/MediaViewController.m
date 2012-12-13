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
- (AVCaptureDevice *) audioDevice;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position;
- (AVCaptureDevice *)frontFacingCamera;
- (AVCaptureDevice *)backFacingCamera;

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
    
    AVCaptureSession *session = [self session];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
    
    [session beginConfiguration];
    [session addInput:newAudioInput];
    [session addInput:newVideoInput];
    [session commitConfiguration];

    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [[self movieFileOutput] startRecordingToOutputFileURL:[self tempFileURL]
                                        recordingDelegate:self];
    [self.view addSubview:_recordView];
    
    
    [session startRunning];
    
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
}

#pragma mark - AVCaptureFileOutputRecordingDelegate Methods
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
- (NSURL *) tempFileURL
{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *unixTime = [NSString stringWithFormat:@"%0.0f", time];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@.mov", NSTemporaryDirectory(), unixTime];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    return outputURL;
}

- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

@end