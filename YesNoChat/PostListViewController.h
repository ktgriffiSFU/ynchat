//
//  PostListViewController.h
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-08.
//  Copyright © 2016 Mimo Films. All rights reserved.
//


#import <UIKit/UIKit.h>
@import FirebaseDatabaseUI;
@import Firebase;

@interface PostListViewController : UIViewController <UITableViewDelegate>
// [START define_database_reference]
@property (strong, nonatomic) FIRDatabaseReference *ref;
// [END define_database_reference]
@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (NSString *) getUid;
@end