//
//  ViewController.m
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "CameraViewController.h"
#import "UploadViewController.h"

@interface CameraViewController ()

@property (strong, nonatomic) UIImagePickerController *pickerController;

@end

@implementation CameraViewController
@synthesize pickerController = _pickerController;
@synthesize cameraButton = _cameraButton;

#pragma mark - Memory Management Methods
- (void)dealloc
{
    self.cameraButton = nil;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Public Methods
- (void)cameraButtonAction:(id)sender
{
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.pickerController.delegate = self;
    [self presentViewController:_pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerOrientation Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // First, initialize and push shareViewController on UIImageController (which is a subclass of UInavigationController)
    UploadViewController *uploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
    [self.pickerController pushViewController:uploadViewController animated:YES];
    
    // Pass video from pickerController to uploadViewController
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Do nothing
}

@end