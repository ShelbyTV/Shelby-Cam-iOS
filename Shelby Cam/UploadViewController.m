//
//  UploadViewController.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "UploadViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLYouTube.h"


@interface UploadViewController ()

@property (strong, nonatomic) GTMOAuth2Authentication *googleAuth;
@property (strong, nonatomic) NSURL *videoURL;

- (void)authenticateWithGoogle;
- (void)uploadVideo;

@end

@implementation UploadViewController
@synthesize googleAuth = _googleAuth;
@synthesize videoURL = _videoURL;

#pragma mark - Memory Deallocation Methods
- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
     andLocalVideoURL:(NSURL *)videoURL
{
    
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.videoURL =videoURL;
    }

    return self;
    
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self authenticateWithGoogle];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - Private Methods
- (void)authenticateWithGoogle
{
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
        [self uploadVideo];
        
    }
}

- (void)uploadVideo
{
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_videoURL.absoluteString];
//    DLog(@"%@", _videoURL.absoluteString);
//    DLog(@"INSIDE");
//    NSString *mimeType = @"video/mp4";
//    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
//                                                                                       MIMEType:mimeType];
//    
//    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
//    
//    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
//                                                                        part:[NSString stringWithFormat:@"Part"]
//                                                            uploadParameters:uploadParameters];
//    
//    GTLServiceYouTube *youTubeService = [[GTLServiceYouTube alloc] init];
//    GTLServiceTicket *ticket = [youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
//        
//        DLog(@"Error: %@", error);
//        DLog(@"Ticket %@", ticket);
//        DLog(@"Object %@", object);
//    }];
//    
//    DLog(@"Outer ticket: %@", ticket);
}

#pragma mark - GTMO2Auth2ViewControllerTouchDelegate Methods
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if ( error ) {
        
        DLog(@"Google OAuth2 Authentication Failed");
        
    } else {
        
        DLog(@"Google OAuth2 Authentication Succeeded");
        [self uploadVideo];
    
    }
}

@end