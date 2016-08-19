//
//  PostTableViewCell.m
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-08.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import "PostTableViewCell.h"
@import Firebase;

@interface PostTableViewCell ()
@property (strong, nonatomic) FIRDatabaseReference *postRef;
@end

@implementation PostTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}



@end