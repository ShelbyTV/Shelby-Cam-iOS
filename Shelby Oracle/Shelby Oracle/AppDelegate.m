//
//  AppDelegate.m
//  Shelby Oracle
//
//  Created by Arthur Ariel Sabintsev on 12/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "AppDelegate.h"
#import "MediaViewController.h"
#import "LoginViewController.h"
#import "RollViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic) LoginViewController *loginViewController;

- (void)setupObservers;
- (void)userDidAuthenticate:(NSNotification*)notification;

@end

@implementation AppDelegate
@synthesize tabBarController = _tabBarController;
@synthesize loginViewController = _loginViewController;

#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Build Window and rootView
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    MediaViewController *mediaViewController = [[MediaViewController alloc] initWithNibName:@"MediaViewController" bundle:nil];
    RollViewController *rollViewController = [[RollViewController alloc] initWithNibName:@"RollViewController" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[mediaViewController, rollViewController];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    if ( ![[NSUserDefaults standardUserDefaults] objectForKey:kShelbyAuthToken] ) {
        
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.window.rootViewController presentViewController:_loginViewController animated:YES completion:nil];
        
    } else {
        
         // User Authenticated - do nothing.
        
    }
    
    
    // Add Observers
    [self setupObservers];
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private Methods
- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidAuthenticate:)
                                                 name:kShelbyUserDidAuthenticate
                                               object:nil];
}

- (void)userDidAuthenticate:(NSNotification *)notification
{
    if ( _loginViewController ) [self.loginViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
