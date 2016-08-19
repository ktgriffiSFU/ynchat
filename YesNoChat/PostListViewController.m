//
//  PostListViewController.m
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-08.
//  Copyright © 2016 Mimo Films. All rights reserved.
//
//

#import "PostListViewController.h"
#import "Post.h"
#import "PostTableViewCell.h"
#import "PostDataSource.h"
#import "PostDetailTableViewController.h"

@import Firebase;

@implementation PostListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [START create_database_reference]
    self.ref = [[FIRDatabase database] reference];
    // [END create_database_reference]
    
    self.dataSource = [[PostDataSource alloc] initWithQuery:[self getQuery]
                                                 modelClass:[Post class]
                                                   nibNamed:@"PostTableViewCell"
                                        cellReuseIdentifier:@"post"
                                                       view:self.tableView];
    
    [self.dataSource
     populateCellWithBlock:^void(PostTableViewCell *__nonnull cell,
                                 Post *__nonnull post) {
         cell.authorLabel.text = post.author;
         cell.postTitle.text = post.author;
         cell.postBody.text = post.question;
     }];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"detail" sender:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (NSString *) getUid {
    return [FIRAuth auth].currentUser.uid;
}

- (FIRDatabaseQuery *) getQuery {
    return self.ref;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = sender;
    PostDetailTableViewController *detail = segue.destinationViewController;
    FirebaseTableViewDataSource *source = self.dataSource;
    FIRDataSnapshot *snapshot = [source objectAtIndex:path.row];
    detail.postKey = snapshot.key;
}
@end