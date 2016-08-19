//
//  FirstViewController.m
//  YesNoChat
//
//  Created by Kyle Griffith on 2016-08-02.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "AppDelegate.h"

@import Firebase;
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions =  @[@"email"];
    CGFloat screenWidth=[[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight=[[UIScreen mainScreen] bounds].size.height;
    
    
    loginButton.center =CGPointMake(screenWidth/2, screenHeight/2);
    [self.view addSubview:loginButton];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)goToWorld{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:appDelegate.tabBarController];
    [appDelegate.window makeKeyAndVisible];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([FBSDKAccessToken currentAccessToken]) {
        //user is logged in
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      // ...
                                  }];
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(50,50,100,100)];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *nameOfLoginUser = [result valueForKey:@"name"];
                NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                NSLog(@"Name:%@",nameOfLoginUser);
                NSLog(@"String:%@",imageStringOfLoginUser);
                NSString *name = [result valueForKey:@"name"];
                NSLog(@"name:%@",name);
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"usersName"];
                
                NSURL *url = [[NSURL alloc] initWithString: imageStringOfLoginUser];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];
                imageView.image=img;
                [self.view addSubview:imageView];
                [self createContinueButton];
                
            }
        }];
        
        
        
        
    }

}
-(void)createContinueButton{
    CGFloat screenWidth=[[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight=[[UIScreen mainScreen] bounds].size.height;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Continue" forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = CGPointMake(screenWidth/2, screenHeight*2/3);
    
    
    // Add an action in current code file (i.e. target)
    [button addTarget:self action:@selector(goToWorld)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}
@end
