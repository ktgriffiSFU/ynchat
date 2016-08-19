//
//  SimpleTableViewController.m
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import "WorldFeedViewController.h"
#import "AppDelegate.h"
#import "YesNoCell.h"
#import "NewPostViewController.h"
#import "SecondViewController.h"
#import "User.h"
#import "Post.h"
#import "PostDataSource.h"
#import "PostTableViewCell.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "LoginViewController.h"
@import Firebase;
@interface  WorldFeedViewController()<UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>{
    FIRDatabaseHandle _refHandle;
    FIRDatabaseHandle _imagesRefHandle;
    NSCache *_imageCache;
    
    
}
@property (strong, nonatomic) FIRDatabaseReference *postRef;
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *posts;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
// [END define_database_reference]
//@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end

@implementation WorldFeedViewController
const int numberOfPosts=5;
bool makeSpaceForPhoto;
NSArray *questions;
NSArray *authors;
UILabel *nameLabel;
UIImageView *profileIcon,*fullView;
UIButton *vipButton;
UILabel *timeStampLabel;
UILabel *questionLabel;
UIButton *yesVoteButton;
UIButton *noVoteButton;
UILabel *yesCountLabel;
UILabel *noCountLabel;
UILabel *locationLabel;
UIImageView *postIcon;
UIButton *fullScreenButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"Initialize the first Tab");
    
    if (self) {
        //set the title for the tab
        self.title = @"First Tab";
        //set the image icon for the tab
        self.tabBarItem.image = [UIImage imageNamed:@"first.png"];
    }
    _imageCache=[[NSCache alloc]init];

    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _tableView.allowsSelection = NO;
    
    if(![FBSDKAccessToken currentAccessToken]){
        LoginViewController *newVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        
        
        [self presentViewController:newVC animated:YES completion:nil];
    }
    [self.tableView registerClass:UITableViewCell.self forCellReuseIdentifier:@"tableViewCell"];
    
    _posts= [[NSMutableArray alloc] init];
    [self configureDatabase];
    [self configureStorage];
    
}

- (NSString *) getUid {
    return [FIRAuth auth].currentUser.uid;
}
- (FIRDatabaseQuery *) getQuery {
    
    return self.ref;
}
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)viewDidDisappear:(BOOL)animated {
    [self.postRef removeObserverWithHandle:_refHandle];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (makeSpaceForPhoto) {
        return 600;
    }else{
        return 300;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_posts count];
}

-(void)saveDataToArrays{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Unpack message from Firebase DataSnapshot
    
    FIRDataSnapshot *postsSnapshot = _posts[indexPath.row];
    NSDictionary<NSString *, NSString *> *post = postsSnapshot.value;
    NSString *uid = [FIRAuth auth].currentUser.uid;
    NSString *name = post[@"author"];
    NSString *question = post[@"question"];
    NSString *timeSincePosted=post[@"timeStamp"];
    NSString *yesCount=post[@"yesCount"];
    NSString *noCount=post[@"noCount"];
    NSString *imageURL=post[@"imageURL"];
    NSString *profileURL=post[@"profileURL"];
    NSString *key=post[@"key"];
    
    UIImage *postImage = [_imageCache objectForKey:key];
    UIImage *profileImage = [_imageCache objectForKey:uid];
    
    if ([imageURL hasPrefix:@"gs://"]) {
        makeSpaceForPhoto=true;
    }else{
        makeSpaceForPhoto=false;
    }
    
    if(postImage)
    {
        NSLog(@"using Cache");
        dispatch_async(dispatch_get_main_queue(), ^{

        postIcon.image = postImage;
        });

    }else{
        if ([imageURL hasPrefix:@"gs://"]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"Usinge Firebase");
                [[[FIRStorage storage] referenceForURL:imageURL] dataWithMaxSize:INT64_MAX
                                                                      completion:^(NSData *data, NSError *error) {
                                                                          if (error) {
                                                                              NSLog(@"Error downloading: %@", error);
                                                                              return;
                                                                          }
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              postIcon.image = [UIImage imageWithData:data];
                                                                          });
                                                                          [_imageCache setObject:[UIImage imageWithData:data] forKey:key];
                                                                      }];
                

            });
        }
    }
    if(profileImage)
    {
        NSLog(@"USING Cache");
        dispatch_async(dispatch_get_main_queue(), ^{

        profileIcon.image = profileImage;
        });

    }else{
        NSLog(@"USING Firebase");

        if([profileURL hasPrefix:@"gs://"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[[FIRStorage storage] referenceForURL:profileURL] dataWithMaxSize:INT64_MAX
                                                                        completion:^(NSData *data, NSError *error) {
                                                                            if (error) {
                                                                                NSLog(@"Error downloading: %@", error);
                                                                                return;
                                                                            }
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                profileIcon.image = [UIImage imageWithData:data];
                                                                            });
                                                                            [_imageCache setObject:[UIImage imageWithData:data] forKey:uid];

                                                                        }];
            });

        }
    }
    NSString *timeDifference=[self convertTimeStamp:timeSincePosted];
    
    static NSString *simpleTableIdentifier = @"YesNoCell";
    CGFloat screenWidth=[[UIScreen mainScreen] bounds].size.width;
    CGFloat viewHeight=300; //change to make different for picture
    CGFloat offset;
    YesNoCell *cell = (YesNoCell *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[YesNoCell alloc]init];
        profileIcon=[[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/20, screenWidth/20, screenWidth/5, screenWidth/5)];
        postIcon=[[UIImageView alloc]initWithFrame:CGRectMake(0, screenWidth/20+viewHeight/10+viewHeight/4, screenWidth, screenWidth*3/4)];
        fullScreenButton=[[UIButton alloc]initWithFrame:CGRectMake(0, screenWidth/20+viewHeight/10+viewHeight/4, screenWidth, screenWidth*3/4)];
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*3/10, screenWidth/20,screenWidth/4,viewHeight/8)];
        vipButton=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth*5.5/10, screenWidth/20, screenWidth/10, viewHeight/10)];
        timeStampLabel=[[UILabel alloc]initWithFrame:CGRectMake(screenWidth*3/4, screenWidth/20, screenWidth/4, viewHeight/10)];
        questionLabel=[[UILabel alloc]initWithFrame:CGRectMake(screenWidth*3/10, screenWidth/20+viewHeight/10, screenWidth*7/10, viewHeight/4)];
        if (makeSpaceForPhoto) {
            offset=300;
        }else{
            offset=0;
        }
        
        yesVoteButton=[[UIButton alloc] initWithFrame:CGRectMake(screenWidth*2/3, screenWidth/20+viewHeight*3.5/10+offset, screenWidth/7, screenWidth/7)];
        noVoteButton =[[UIButton alloc] initWithFrame:CGRectMake(screenWidth*2/3 +screenWidth/7, screenWidth/20+viewHeight*3.5/10+offset, screenWidth/7, screenWidth/7)];
        yesCountLabel=[[UILabel alloc] initWithFrame:CGRectMake(screenWidth*3/10, screenWidth*27/140+viewHeight*3.5/10+offset,screenWidth/3, viewHeight/8)];
        noCountLabel =[[UILabel alloc]initWithFrame:CGRectMake(screenWidth*19/30, screenWidth*27/140+viewHeight*3.5/10+offset, screenWidth/3, viewHeight/8)];
        locationLabel=[[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4, screenWidth*6/8+offset, screenWidth/2, screenWidth/8)];
        profileIcon.tag=0;
        nameLabel.tag = 1; // Set a constant for this
        vipButton.tag = 2;
        timeStampLabel.tag=3;
        questionLabel.tag=4;
        yesVoteButton.tag=5;
        noVoteButton.tag=6;
        yesCountLabel.tag=7;
        noCountLabel.tag=8;
        locationLabel.tag=9;
        postIcon.tag=10;
        fullScreenButton.tag=11;
        
        nameLabel.numberOfLines=1;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.minimumScaleFactor = 0;
        
        [vipButton setTitle:@"VIP+" forState:UIControlStateNormal];
        [vipButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        vipButton.titleLabel.font = [UIFont systemFontOfSize:10];
        
        timeStampLabel.textColor=[UIColor blackColor];
        timeStampLabel.font=[UIFont systemFontOfSize:10];
        
        questionLabel.numberOfLines=3;
        questionLabel.textColor=[UIColor blackColor];
        questionLabel.textAlignment=NSTextAlignmentLeft;
        questionLabel.font=[UIFont systemFontOfSize:13];
        questionLabel.backgroundColor=[UIColor yellowColor];
        
        [yesVoteButton setTitle:@"Yes" forState:UIControlStateNormal];
        [yesVoteButton addTarget:self
                          action:@selector(updateYesOrNoCount:)
                forControlEvents:UIControlEventTouchUpInside];
        yesVoteButton.titleLabel.font=[UIFont systemFontOfSize:15];
        [yesVoteButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [noVoteButton setTitle:@"No" forState:UIControlStateNormal];
        [noVoteButton addTarget:self
                         action:@selector(updateYesOrNoCount:)
               forControlEvents:UIControlEventTouchUpInside];
        
        noVoteButton.titleLabel.font=[UIFont systemFontOfSize:15];
        [noVoteButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        
        yesCountLabel.numberOfLines=1;
        yesCountLabel.textAlignment = NSTextAlignmentLeft;
        yesCountLabel.textColor = [UIColor blackColor];
        yesCountLabel.adjustsFontSizeToFitWidth = YES;
        yesCountLabel.minimumScaleFactor = 0;
        
        noCountLabel.numberOfLines=1;
        noCountLabel.textAlignment = NSTextAlignmentRight;
        noCountLabel.textColor = [UIColor blackColor];
        noCountLabel.adjustsFontSizeToFitWidth = YES;
        noCountLabel.minimumScaleFactor = 0;
        
        locationLabel.numberOfLines=1;
        locationLabel.textAlignment = NSTextAlignmentCenter;
        locationLabel.textColor = [UIColor blackColor];
        locationLabel.adjustsFontSizeToFitWidth = YES;
        locationLabel.minimumScaleFactor = 0;
        
        postIcon.userInteractionEnabled = YES;
        
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:vipButton];
        [cell.contentView addSubview:timeStampLabel];
        [cell.contentView addSubview:profileIcon];
        [cell.contentView addSubview:questionLabel];
        [cell.contentView addSubview:yesCountLabel];
        [cell.contentView addSubview:noCountLabel];
        [cell.contentView addSubview:locationLabel];
        [cell.contentView addSubview:postIcon];
        [cell.contentView addSubview:yesVoteButton];
        [cell.contentView addSubview:noVoteButton];
        // [cell.contentView addSubview:fullScreenButton];
        
    } else {
        profileIcon=(UIImageView *)[cell.contentView viewWithTag:0];
        nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        vipButton = (UIButton *)[cell.contentView viewWithTag:2];
        timeStampLabel=(UILabel *)[cell.contentView viewWithTag:3];
        questionLabel =(UILabel *)[cell.contentView viewWithTag:4];
        yesVoteButton=(UIButton *)[cell.contentView viewWithTag:5];
        noVoteButton=(UIButton *)[cell.contentView viewWithTag:6];
        yesCountLabel=(UILabel *)[cell.contentView viewWithTag:7];
        noCountLabel=(UILabel *)[cell.contentView viewWithTag:8];
        locationLabel=(UILabel *)[cell.contentView viewWithTag:9];
        postIcon = (UIImageView *)[cell.contentView viewWithTag:10];
        fullScreenButton=(UIButton *)[cell.contentView viewWithTag:11];
    }
    
    
    
    nameLabel.text = name;
    timeStampLabel.text=timeDifference;
    
    questionLabel.text=question;
    yesCountLabel.text=[NSString stringWithFormat:@"Yes: %@",yesCount];
    noCountLabel.text=[NSString stringWithFormat:@"No: %@",noCount];
    locationLabel.text=@"Fresno, California";
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = tableView.frame;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height+30)];
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width-70, 30)];
    questionLabel.text = @"Ask your own Yes No question";
    questionLabel.textColor=[UIColor grayColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-30, 0, 30, 30)];
    button.backgroundColor=[UIColor blackColor];
    [button addTarget:self
               action:@selector(submitQuestion)
     forControlEvents:UIControlEventTouchUpInside];
    headerView.backgroundColor=[UIColor whiteColor];
    
    [headerView addSubview:button];
    [headerView addSubview:questionLabel];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return  [UIApplication sharedApplication].statusBarFrame.size.height+30;
}
-(void)submitQuestion {
    NSLog(@"Button was pressed");
    NewPostViewController *newVC = [[NewPostViewController alloc] initWithNibName:@"NewPostViewController" bundle:nil];
    
    
    [self presentViewController:newVC animated:YES completion:nil];
}
- (void)configureDatabase {
    _ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database
    
    
    _refHandle = [[[[_ref child:@"posts"]queryOrderedByChild:@"inverseTimeStamp"] queryLimitedToFirst:numberOfPosts]observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [_posts addObject:snapshot];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
        
        
    }];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    
    
    
}
- (void)configureStorage {
    self.storageRef = [[FIRStorage storage] referenceForURL:@"gs://yesnochat.appspot.com"];
}
-(NSString *)convertTimeStamp :(NSString *)myTimeStamp{
    
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger myTimeStampNumber=[myTimeStamp integerValue];
    NSInteger currentTimeStampNumber=[@(nowInterval) integerValue];
    NSInteger timeDisplacement=currentTimeStampNumber-myTimeStampNumber;
    
    CGFloat days;
    CGFloat remainder;
    CGFloat hours;
    CGFloat minutes;
    CGFloat seconds;
    NSString *timeStampString;
    
    if (timeDisplacement/(24*60*60)>1) {
        days=timeDisplacement/(24*60*60);
        remainder=days-floorf(days);
        timeStampString=[NSString stringWithFormat:@"%.00f days ago",days];
    }else{
        days=0;
        remainder=timeDisplacement;
        if(remainder/(60*60)>1){
            hours=remainder/(60*60);
            remainder=hours-floorf(hours);
            timeStampString=[NSString stringWithFormat:@"%.00f hours ago",hours];
        }else{
            hours=0;
            if(remainder/60>1){
                minutes=remainder/60;
                remainder=minutes-floorf(minutes);
                timeStampString=[NSString stringWithFormat:@"%.00f minutes ago",minutes];
            }else{
                minutes=0;
                seconds=remainder;
                timeStampString=[NSString stringWithFormat:@"%.00f seconds ago",seconds];
                if (remainder<1) {
                    timeStampString=[NSString stringWithFormat:@"Just now"];
                    
                }
            }
        }
        
    }
    
    
    return timeStampString;
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //  NSLog(@"Did Scroll");
}
- (void)cellImageTapped:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@", [gestureRecognizer view]);
    //create new image
    UIImageView  *temptumb=(UIImageView *)gestureRecognizer.view;
    //temptumb=thumbnail;
    fullView=[[UIImageView alloc]init];
    [fullView setContentMode:UIViewContentModeScaleAspectFit];
    fullView.image = [(UIImageView *)gestureRecognizer.view image];
    CGRect point=[self.view convertRect:gestureRecognizer.view.bounds fromView:gestureRecognizer.view];
    [fullView setFrame:point];
    
    [self.view addSubview:fullView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [fullView setFrame:CGRectMake(0,
                                                       0,
                                                       self.view.bounds.size.width,
                                                       self.view.bounds.size.height)];
                     }];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullimagetapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [fullView addGestureRecognizer:singleTap];
    [fullView setUserInteractionEnabled:YES];
    NSLog(@"cell tapped");
}
-(void)updateYesOrNoCount :(UIButton *)sender{
    bool votedYes;
    
    
    if(sender.tag==5){
        NSLog(@"Yes button pressed");
        votedYes=true;
    }else{
        NSLog(@"No button Pressed");
        
        votedYes=false;
    }
    NSArray *visible       = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = (NSIndexPath*)[visible objectAtIndex:0];
    FIRDataSnapshot *postsSnapshot = _posts[indexPath.row];
    NSDictionary *post = postsSnapshot.value;
    NSString *name = post[@"author"];
    NSString *question = post[@"question"];
    NSString *timeSincePosted=post[@"timeStamp"];
    NSNumber *yesCount=post[@"yesCount"];
    NSNumber *noCount=post[@"noCount"];
    NSString *imageURL=post[@"imageURL"];
    NSString *profileURL=post[@"profileURL"];
    NSString *key =post[@"key"];
    NSString *inverseTimeStamp=post[@"inverseTimeStamp"];
    NSMutableDictionary *userVotes = [post objectForKey:@"voters"];
    if (!userVotes) {
        userVotes = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    NSString *uid = [FIRAuth auth].currentUser.uid;
    int voteCount;
    if (votedYes) {
        voteCount= [post[@"yesCount"] intValue];
        
    }else{
        voteCount=[post[@"noCount"] intValue];
    }
    if (![userVotes objectForKey:uid]) {
        voteCount++;
        userVotes[uid] = @YES;
    }
    // postCurrent[@"voters"] = userVotes;
    if (votedYes) {
        noCount=post[@"noCount"];
        yesCount=[NSNumber numberWithInt:voteCount];
    }else{
        noCount =[NSNumber numberWithInt:voteCount];
        yesCount= post[@"yesCount"];
    }
    if (noCount==nil) {
        noCount=[NSNumber numberWithInt:0];;
    }
    if (yesCount==nil) {
        yesCount=[NSNumber numberWithInt:0];
    }
    NSDictionary *postToSend = @{@"uid":uid,
                                 @"yesCount":yesCount,
                                 @"noCount" :noCount,
                                 @"voters":userVotes,
                                 @"question":question,
                                 @"timeStamp":timeSincePosted,
                                 @"inverseTimeStamp":inverseTimeStamp,
                                 @"author":name,
                                 @"imageURL":imageURL,
                                 @"profileURL":profileURL,
                                 @"key":key};
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: postToSend,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", uid, key]: postToSend};
    [_ref updateChildValues:childUpdates];
    yesCountLabel.text=[NSString stringWithFormat:@"Yes: %@",yesCount];
    noCountLabel.text=[NSString stringWithFormat:@"No: %@",noCount];
}
@end

