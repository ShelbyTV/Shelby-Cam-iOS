//
//  UploadViewController.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "UploadViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"


@interface UploadViewController ()

@property (strong, nonatomic) GTMOAuth2Authentication *googleAuth;

@end

@implementation UploadViewController
@synthesize googleAuth = _googleAuth;

#pragma mark - Memory Deallocation Methods
- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kYouTubeKeychainName
                                                                                          clientID:kYouTubeClientID
                                                                                      clientSecret:kYouTubeClientSecret];

    BOOL didAuthBefore = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:kYouTubeKeychainName authentication:auth];
    
    if ( NO == didAuthBefore ) {
        
        DLog(@"User must authenticate with Google/YouTube");
        
        GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kYoutubeScope
                                                                                                  clientID:kYouTubeClientID
                                                                                              clientSecret:kYouTubeClientSecret
                                                                                          keychainItemName:kYouTubeKeychainName
                                                                                                  delegate:self
                                                                                          finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else {
        
        DLog(@"User already authenticated with Google/YouTube");
        
    }

}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if ( error ) {
        
        DLog(@"Google OAuth2 Authentication Failed");
        
    } else {
        
        DLog(@"Google OAuth2 Authentication Succeeded");

    
    }
}

@end