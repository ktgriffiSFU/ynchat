//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NewPostViewController.h"
#import "User.h"
#import "Post.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "AppState.h"
@import Firebase;
@import Photos;

@interface NewPostViewController () <UITextFieldDelegate,UIImagePickerControllerDelegate, UITextViewDelegate>{
    NSURL *pictureURL;
    NSString *pictureString;
    NSString *uniqueString;
    UIButton *takePhoto;
    UIButton *selectPhoto;
    NSData *imageData;
    NSData *profilePicData;
    NSURL *profilePicURL;
}
@property (strong,nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) UIButton *postImageButton;
@property (strong, nonatomic) FIRStorage *storage;

@end

@implementation NewPostViewController

#pragma mark - UIViewController lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // [START create_database_reference]
    self.ref = [[FIRDatabase database] reference];
    // [END create_database_reference]
    UIToolbar *doneBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    doneBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapShare:)];
    CGFloat screenWidth=[[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight=[[UIScreen mainScreen] bounds].size.height;
    _bodyTextView=[[UITextView alloc]initWithFrame:CGRectMake(screenWidth/8, screenHeight/4,screenWidth*3/4 , screenWidth/4)];
    _bodyTextView.text=@"Enter question here";
    _bodyTextView.textColor=[UIColor lightGrayColor];
    _bodyTextView.delegate=self;
    [self.view addSubview:_bodyTextView];
    _postImageButton=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth*6/8, screenHeight*2/8, screenWidth/8, screenWidth/8)];
    _postImageButton.backgroundColor=[UIColor blackColor];
    [_postImageButton addTarget:self
                         action:@selector(postImage)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_postImageButton];
    done.tintColor = [UIColor colorWithRed:1.0 green:143.0/255.0 blue:0.0 alpha:1.0];
    doneBar.items = [NSArray arrayWithObjects:flex, done, flex, nil];
    [doneBar sizeToFit];
    _bodyTextView.inputAccessoryView = doneBar;
    [self getFacebookProfilePicture];
    
    UIButton *exitButton=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth*7/8, screenHeight/8, screenWidth/8, screenWidth/8)];
    [exitButton setTitle:@"X" forState:UIControlStateNormal];
    [exitButton addTarget:self
                   action:@selector(dismissNewPost)
         forControlEvents:UIControlEventTouchUpInside];
    exitButton.titleLabel.textColor=[UIColor whiteColor];
    exitButton.backgroundColor=[UIColor blackColor];
    [self.view addSubview:exitButton];
    
    takePhoto=[[UIButton alloc]initWithFrame:CGRectMake(0, screenHeight/2, screenWidth/2, screenHeight/6)];
    selectPhoto=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2, screenHeight/2, screenWidth/2, screenHeight/6)];
    [selectPhoto setTitle:@"Select Photo" forState:UIControlStateNormal];
    [takePhoto setTitle:@"Take Photo" forState:UIControlStateNormal];
    [selectPhoto addTarget:self
                    action:@selector(selectPhotoPressed)
          forControlEvents:UIControlEventTouchUpInside];
    [takePhoto addTarget:self
                  action:@selector(takePhotoPressed)
        forControlEvents:UIControlEventTouchUpInside];
    takePhoto.backgroundColor=[UIColor redColor];
    selectPhoto.backgroundColor=[UIColor blueColor];
}

- (IBAction)didTapShare:(id)sender {
    // [START single_value_read]
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //Get user value
        
        [[self navigationController] popViewControllerAnimated:YES];
        // [END_EXCLUDE]
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    // Local file you want to upload
    _storage = [FIRStorage storage];
    _storageRef = [_storage referenceForURL:@"gs://yesnochat.appspot.com"];
    NSData *localData=imageData;
    // Create the file metadata
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    FIRStorageMetadata *metadataProfile=[[FIRStorageMetadata alloc]init];
    metadataProfile.contentType=@"image/png";
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *inverseTimeStamp = [NSNumber numberWithDouble:timeInSeconds];
    inverseTimeStamp=@(-inverseTimeStamp.doubleValue);    NSString *timeStamp=[NSString stringWithFormat:@"%f",timeInSeconds];
    NSString *author=[[NSUserDefaults standardUserDefaults]objectForKey:@"usersName"];
    
    if (localData) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%lld/",
                              [FIRAuth auth].currentUser.uid,
                              (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
        [[_storageRef child:filePath]
         putData:localData metadata:metadata
         completion:^(FIRStorageMetadata *metadata, NSError *error) {
             if (error) {
                 NSLog(@"Error uploading: %@", error);
                 return;
             }
             
         }
         ];
        NSString *filePathProfile = [NSString stringWithFormat:@"%@",
                                     [FIRAuth auth].currentUser.uid];
        [[_storageRef child:filePathProfile]
         putData:profilePicData metadata:metadataProfile
         completion:^(FIRStorageMetadata *metadataProfile, NSError *error) {
             if (error) {
                 NSLog(@"Error uploading: %@", error);
                 return;
             }
             
         }
         ];
        [self sendMessage:@{@"imageURL":[_storageRef child:metadata.path].description,
                            @"profileURL":[_storageRef child:metadataProfile.path].description,
                            @"uid":userID,
                            @"timeStamp":timeStamp,
                            @"question":_bodyTextView.text,
                            @"author":author,
                            @"inverseTimeStamp":inverseTimeStamp,
                            @"yesCount":[NSNumber numberWithInteger:0],
                            @"noCount":[NSNumber numberWithInteger:0]}];
    }else{
        [self writeNewPost:userID username:author question:_bodyTextView.text];
    }
    
    // Write new post
    
    
    
    // [END single_value_read]
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:Nil];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    UIImage *scaledImage = [self scaleImage:image toSize:CGSizeMake(175,175)]; // or some other size
    // pictureURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    imageData = UIImagePNGRepresentation(scaledImage);
    
    
}

- (void)writeNewPost:(NSString *)userID username:(NSString *)username question:(NSString *)question {
    FIRStorageMetadata *metadataProfile=[[FIRStorageMetadata alloc]init];
    metadataProfile.contentType=@"image/png";
    NSString *key = [[_ref child:@"posts"] childByAutoId].key;
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *inverseTimeStamp = [NSNumber numberWithDouble:timeInSeconds];
    inverseTimeStamp=@(-inverseTimeStamp.doubleValue);
    NSString *timeStamp=[NSString stringWithFormat:@"%f",timeInSeconds];
    NSString *filePathProfile = [NSString stringWithFormat:@"%@",
                                 [FIRAuth auth].currentUser.uid];
    [[_storageRef child:filePathProfile]
     putData:profilePicData metadata:metadataProfile
     completion:^(FIRStorageMetadata *metadataProfile, NSError *error) {
         if (error) {
             NSLog(@"Error uploading: %@", error);
             return;
         }
         
     }
     ];
    NSDictionary *post = @{@"uid": userID,
                           @"author": username,
                           @"question": question,
                           @"yesCount":@0,
                           @"noCount":@0,
                           @"timeStamp":timeStamp,
                           @"inverseTimeStamp":inverseTimeStamp,
                           @"imageURL":@"noPhoto",
                           @"key":key,
                           @"profileURL":[_storageRef child:metadataProfile.path].description};
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: post,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", userID, key]: post};
    [_ref updateChildValues:childUpdates];
    
    // [END write_fan_out]
}
- (UIImage *) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)sendMessage:(NSDictionary *)data {
    NSMutableDictionary *mdata = [data mutableCopy];
    NSURL *photoUrl = AppState.sharedInstance.photoUrl;
    if (photoUrl) {
        mdata[@"imageURL"] = [photoUrl absoluteString];
    }
    mdata[@"uid"]=[FIRAuth auth].currentUser.uid;
    NSString *key = [[_ref child:@"posts"] childByAutoId].key;
    NSString *userID = [FIRAuth auth].currentUser.uid;
    mdata[@"key"]=key;
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: mdata,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", userID, key]: mdata};
    [_ref updateChildValues:childUpdates];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
-(void)getFacebookProfilePicture{
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
                UIImage *scaledImage = [self scaleImage:img toSize:CGSizeMake(25,25)]; // or some other size
                profilePicData = UIImagePNGRepresentation(scaledImage);
                
                
            }
        }];
    }
    
}
-(void)postImage{
    [self.view addSubview:selectPhoto];
    [self.view addSubview:takePhoto];
    
    //    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    //    picker.delegate = self;
    //    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    } else {
    //        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    }
    //
    //    [self presentViewController:picker animated:YES completion:NULL];
}


- (IBAction)takePhotoPressed {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}
- (IBAction)selectPhotoPressed {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    _bodyTextView.text = @"";
    _bodyTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(_bodyTextView.text.length == 0){
        _bodyTextView.textColor = [UIColor lightGrayColor];
        _bodyTextView.text = @"Enter question here";
        [_bodyTextView resignFirstResponder];
    }
}
-(void)dismissNewPost{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end