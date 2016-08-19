//
//  AppDelegate.m
//  YesNoChat
//
//  Created by Kyle Griffith on 2016-08-02.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginViewController.h"
#import "WorldFeedViewController.h"
#import "SecondViewController.h"
#import "PostListViewController.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FIRApp configure];
    //init the view controllers for the tabs, Home and settings
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    _worldFeedViewController=[[WorldFeedViewController alloc]initWithNibName:nil bundle:NULL];
    UINavigationController *navCntrl1 = [[UINavigationController alloc] initWithRootViewController:_worldFeedViewController];

    _secondViewController=[[SecondViewController alloc]initWithNibName:nil bundle:NULL];
    UINavigationController *navCntrl2 = [[UINavigationController alloc] initWithRootViewController:_secondViewController];

    NSArray *myViewControllers = [[NSArray alloc] initWithObjects:
                                  navCntrl1,
                                  navCntrl2, nil];
    _tabBarController = [[MyUITabBarController alloc] init];
    [_tabBarController setViewControllers:myViewControllers];
    [_window addSubview:_tabBarController.view];
    [_window setRootViewController:_tabBarController];

    [_window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}
- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error{
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      // ...
                                  }];
        NSLog(@"User name: %@",[FBSDKProfile currentProfile].name);
        NSLog(@"User ID: %@",[FBSDKProfile currentProfile].userID);
    } else {
        NSLog(error.localizedDescription);
    }
}
@end
