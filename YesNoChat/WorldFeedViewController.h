//
//  WorldFeedViewController.h
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-03.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseDatabaseUI;
@import Firebase;

@interface WorldFeedViewController : UIViewController
// [START define_database_reference]


- (NSString *) getUid;
@end