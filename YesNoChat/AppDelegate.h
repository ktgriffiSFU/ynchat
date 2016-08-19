//
//  AppDelegate.h
//  YesNoChat
//
//  Created by Kyle Griffith on 2016-08-02.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondViewController.h"
#import "WorldFeedViewController.h"
#import "MyUITabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MyUITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) WorldFeedViewController *worldFeedViewController;
@property (strong, nonatomic) SecondViewController *secondViewController;

@end

