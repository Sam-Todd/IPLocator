//
//  IPHelper.h
//  IPLocator
//
//  Created by Samantha Todd on 10/7/16.
//  Copyright © 2016 Samantha Todd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPHelper : NSObject

+ (NSString *)ipFromLong:(long long)value;
+ (long long)longFromIP:(NSString *)ip;

@end
