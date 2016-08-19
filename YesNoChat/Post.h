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

#import <Foundation/Foundation.h>

@interface Post : NSObject
@property(strong, nonatomic) NSString *uid;
@property(strong, nonatomic) NSString *author;
@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *body;
@property(assign, nonatomic) int starCount;
@property(strong, nonatomic) NSDictionary <NSString *, NSNumber *> *stars;

- (instancetype)initWithAuthor:(NSString *)author
                       andBody:(NSString *)body
                      andTitle:(NSString *)title
                        andUid:(NSString *)author;

@end