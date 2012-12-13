//
//  ViewController.h
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

- (IBAction)cameraButtonAction:(id)sender;

@end
