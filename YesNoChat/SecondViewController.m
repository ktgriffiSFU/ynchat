//
//  SecondViewController.m
//  YesNoChat
//
//  Created by Kyle Griffith on 2016-08-02.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"Initialize the second Tab");
    
    if (self) {
        self.title = @"Second Tab";
        self.tabBarItem.image = [UIImage imageNamed:@"second.png"];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
