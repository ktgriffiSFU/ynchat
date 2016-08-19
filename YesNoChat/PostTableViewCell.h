//
//  PostTableViewCell.h
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-08.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface PostTableViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *authorLabel;
@property(weak, nonatomic) IBOutlet UITextView *postBody;
@property(weak, nonatomic) NSString *postKey;
@end