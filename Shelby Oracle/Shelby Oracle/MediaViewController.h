//
//  MediaViewController.h
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController <UIImagePickerControllerDelegate, AVCaptureFileOutputRecordingDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIButton *recordVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseVideoButton;

- (IBAction)recordVideoButtonAction:(id)sender;
- (IBAction)chooseVideoButtonAction:(id)sender;


@end
