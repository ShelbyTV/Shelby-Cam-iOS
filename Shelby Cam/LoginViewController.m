//
//  LoginViewController.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.emailField = nil;
    self.passwordField = nil;
    self.loginButton = nil;
}

#pragma mark - Initialization Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Action Methods
- (IBAction)loginButtonAction:(id)sender
{
    // Resign first responders
    if ( self.emailField.isFirstResponder ) [self.emailField resignFirstResponder];
    if ( self.passwordField.isFirstResponder ) [self.passwordField resignFirstResponder];
    
    if ( ![self.emailField text] || ![self.passwordField text] ) {
        
    } else {
        
        [ShelbyAPIClient postAuthenticationWithEmail:_emailField.text andPassword:_passwordField.text];
        
    }
    
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ( [string isEqualToString:@"\n"] ) {
        
        [textField resignFirstResponder];
        return NO;
        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.emailField ) {

        [self.passwordField becomeFirstResponder];

    } else {
        [self.passwordField resignFirstResponder];
        [self loginButtonAction:nil];

    }
    
    return YES;
}

#pragma mark - UIResponder Methods
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [self.emailField isFirstResponder] ) [self.emailField resignFirstResponder];
    if ( [self.passwordField isFirstResponder] ) [self.passwordField resignFirstResponder];
}

@end