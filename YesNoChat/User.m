//
//  User.m
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-05.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@implementation User

- (instancetype)init {
    return [self initWithUsername:@""];
}

- (instancetype)initWithUsername:(NSString *)username {
    self = [super init];
    if (self) {
        self.username = username;
    }
    return self;
}

@end