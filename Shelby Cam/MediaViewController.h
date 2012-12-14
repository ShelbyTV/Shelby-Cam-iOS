//
//  MediaViewController.h
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController
<
UIImagePickerControllerDelegate,
AVCaptureFileOutputRecordingDelegate,
UINavigationControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *tapToStartImageView;
@property (weak, nonatomic) IBOutlet UIButton *toggleLightButton;
@property (weak, nonatomic) IBOutlet UIButton *flipCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseExistingVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *recordNewVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *presentUserRollButton;


- (IBAction)toggleLightButtonAction:(id)sender;
- (IBAction)flipCameraButtonAction:(id)sender;
- (IBAction)settingsButtonAction:(id)sender;
- (IBAction)chooseExistingVideoButtonAction:(id)sender;
- (IBAction)recordVideoButtonAction:(id)sender;
- (IBAction)presentUserRollButtonAction:(id)sender;


@end
