//
//  User.h
//  YesNoChat
//
//  Created by Mario Pochat on 2016-08-05.
//  Copyright © 2016 Mimo Films. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property(strong, nonatomic) NSString *username;

- (instancetype)initWithUsername:(NSString *)username;

@end