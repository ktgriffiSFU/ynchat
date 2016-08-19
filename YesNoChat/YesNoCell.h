//
//  YesNoCell.h
//  YesNoChat
//
//  Created by Kyle Griffith on 2016-08-03.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YesNoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterIcon;
@property (weak, nonatomic) IBOutlet UILabel *posterLabel;
@property (weak, nonatomic) IBOutlet UIButton *vipUpVote;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *voteYesButton;
@property (weak, nonatomic) IBOutlet UIButton *voteNoButton;
@property (weak, nonatomic) IBOutlet UILabel *yesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *noCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterLocationLabel;

@end

