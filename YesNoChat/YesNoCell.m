//
//  yesNoCell.m
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-03.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import "YesNoCell.h"

@implementation YesNoCell
@synthesize posterIcon=_posterIcon,
            posterLabel=_posterLabel,
            vipUpVote=_vipUpVote,
            timeStampLabel=_timeStampLabel,
            questionLabel=_questionLabel,
            voteNoButton=_voteNoButton,
            voteYesButton=_voteYesButton,
            yesCountLabel=_yesCountLabel,
            noCountLabel=_noCountLabel,
            //favoriteButton=_favoriteButton,
            posterLocationLabel=_posterLocationLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end