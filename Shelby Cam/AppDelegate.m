//
//  AppDelegate.m
//  Shelby Chat
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "AppDelegate.h"
#import "MediaViewController.h"
#import "ShelbyLoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UINavigationController *loginNavigationController;

- (void)setupObservers;
- (void)userDidAuthenticate:(NSNotification*)notification;
- (void)presentLoginViewController;

@end

@implementation AppDelegate
@synthesize navigationController = _navigationController;
@synthesize loginNavigationController = _loginNavigationController;

#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Add Observers
    [self setupObservers];
    
    // Build Window and rootView
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MediaViewController *mediaViewController = [[MediaViewController alloc] initWithNibName:@"MediaViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mediaViewController];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
    if ( ![[NSUserDefaults standardUserDefaults] objectForKey:kShelbyAuthToken] ) {
        
        [self presentLoginViewController];
        
    } else {
        
         // User Authenticated - do nothing.
        
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Public Methods
- (void)logout
{
    // Remove Shelby Token
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kShelbyAuthToken];
    
    // Remove Google Authorization
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kYouTubeKeychainName
                                                                                          clientID:kYouTubeClientID
                                                                                      clientSecret:kYouTubeClientSecret];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    
    // Present LoginViewController
    [self presentLoginViewController];
}

#pragma mark - Private Methods
- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidAuthenticate:)
                                                 name:kShelbyUserDidAuthenticate
                                               object:nil];
}

- (void)presentLoginViewController
{
    ShelbyLoginViewController *shelbyLoginViewController = [[ShelbyLoginViewController alloc] initWithNibName:@"ShelbyLoginViewController" bundle:nil];
    self.loginNavigationController = [[UINavigationController alloc] initWithRootViewController:shelbyLoginViewController];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topBar"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.loginNavigationController.visibleViewController.navigationItem.titleView = logoView;
    [self.window.rootViewController presentViewController:_loginNavigationController animated:YES completion:nil];
}

- (void)userDidAuthenticate:(NSNotification *)notification
{
    if ( _loginNavigationController ) [self.loginNavigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
